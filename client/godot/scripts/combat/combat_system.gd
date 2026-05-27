class_name CombatSystem
extends RefCounted

const CombatConfig := preload("res://scripts/combat/combat_config.gd")
const CombatDamage := preload("res://scripts/combat/combat_damage.gd")
const EntityCombat := preload("res://scripts/combat/entity_combat.gd")
const CombatRng := preload("res://scripts/combat/combat_rng.gd")

var config: CombatConfig = null
var _entities: Dictionary = {}
var _monster_defs: Dictionary = {}
var _world = null
var _desired_range: int = 1
var _player_xp: int = 0
var _player_gold: int = 0
var _rng: CombatRng = CombatRng.new()
var _last_attack_ok: bool = false


func setup(p_world, p_config: CombatConfig, monster_defs: Dictionary = {}) -> void:
	_world = p_world
	config = p_config
	_monster_defs = monster_defs
	_desired_range = config.melee_range


func set_rng_seed(seed_value: int) -> void:
	_rng.seed(seed_value)


func register_player(entity_id: StringName, profile: Dictionary = {}) -> void:
	var defaults := config.player_defaults if config else {}
	var merged := defaults.duplicate()
	for key in profile:
		merged[key] = profile[key]
	var ec := EntityCombat.new()
	ec.entity_id = entity_id
	ec.is_player = true
	ec.max_hp = int(merged.get("hp", 100))
	ec.hp = ec.max_hp
	ec.player_profile = merged
	_entities[entity_id] = ec


func register_monster(entity_id: StringName, mob_id: String) -> void:
	var def: Dictionary = _monster_defs.get(mob_id, {})
	var ec := EntityCombat.new()
	ec.entity_id = entity_id
	ec.mob_id = mob_id
	ec.max_hp = int(def.get("hp", 1))
	ec.hp = ec.max_hp
	ec.defense = int(def.get("defense", 0))
	_entities[entity_id] = ec


func set_player_class(class_id: String) -> void:
	var player := _entities.get(&"player") as EntityCombat
	if player != null:
		player.player_profile["class"] = class_id


func set_desired_range(tiles: int) -> void:
	_desired_range = clampi(tiles, config.melee_range, config.max_desired_range)


func get_desired_range() -> int:
	return _desired_range


func get_hp(entity_id: StringName) -> int:
	var ec: EntityCombat = _entities.get(entity_id)
	return ec.hp if ec != null else 0


func get_mob_id(entity_id: StringName) -> String:
	var ec: EntityCombat = _entities.get(entity_id)
	return ec.mob_id if ec != null else ""


func is_entity_alive(entity_id: StringName) -> bool:
	var ec: EntityCombat = _entities.get(entity_id)
	return ec != null and ec.is_alive()


func list_mob_entity_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for key in _entities:
		var ec: EntityCombat = _entities[key]
		if not ec.is_player:
			ids.append(key)
	return ids


func get_player_xp() -> int:
	return _player_xp


func get_player_gold() -> int:
	return _player_gold


func tile_distance(a: StringName, b: StringName) -> int:
	## Chebyshev (incluye diagonal): 1 = casilla vecina en 8 direcciones.
	var pa: Vector2i = _world.get_entity_position(a)
	var pb: Vector2i = _world.get_entity_position(b)
	return maxi(absi(pa.x - pb.x), absi(pa.y - pb.y))


func attack_range_for(attacker_id: StringName) -> int:
	var ec: EntityCombat = _entities.get(attacker_id)
	if ec == null:
		return 0
	if ec.is_player:
		var class_id := str(ec.player_profile.get("class", "warrior"))
		if class_id in ["mage", "archer"]:
			return _desired_range
		return config.melee_range
	return config.melee_range


func can_attack(attacker_id: StringName, target_id: StringName) -> bool:
	var attacker: EntityCombat = _entities.get(attacker_id)
	var target: EntityCombat = _entities.get(target_id)
	if attacker == null or target == null:
		return false
	if not attacker.is_alive() or not target.is_alive():
		return false
	if attacker_id == target_id:
		return false
	if attacker.is_player == target.is_player:
		return false
	if attacker.cooldown_ticks > 0:
		return false
	var dist := tile_distance(attacker_id, target_id)
	return dist >= 1 and dist <= attack_range_for(attacker_id)


func nearest_enemy(from_id: StringName, max_range: int) -> StringName:
	var best_id := StringName()
	var best_dist := max_range + 1
	for key in _entities:
		var ec: EntityCombat = _entities[key]
		if key == from_id or not ec.is_alive():
			continue
		var from_ec: EntityCombat = _entities[from_id]
		if from_ec != null and from_ec.is_player == ec.is_player:
			continue
		var dist := tile_distance(from_id, key)
		if dist <= max_range and dist < best_dist:
			best_dist = dist
			best_id = key
	return best_id


func nearest_attackable_enemy(from_id: StringName) -> StringName:
	var best_id := StringName()
	var best_dist := 999
	for key in _entities:
		if not can_attack(from_id, key):
			continue
		var dist := tile_distance(from_id, key)
		if dist < best_dist:
			best_dist = dist
			best_id = key
	return best_id


func process_attack(attacker_id: StringName, target_id: StringName) -> Dictionary:
	_last_attack_ok = false
	if not can_attack(attacker_id, target_id):
		return {"ok": false, "damage": 0, "killed": false}
	var attacker: EntityCombat = _entities[attacker_id]
	var target: EntityCombat = _entities[target_id]
	var dmg := _compute_damage(attacker, target)
	target.hp = maxi(0, target.hp - dmg)
	attacker.reset_cooldown(config.attack_cooldown_ticks)
	var killed := not target.is_alive()
	if killed and not target.is_player:
		_grant_kill_rewards(target.mob_id)
	_last_attack_ok = true
	return {"ok": true, "damage": dmg, "killed": killed}


func tick_cooldowns() -> void:
	for key in _entities:
		var ec: EntityCombat = _entities[key]
		ec.tick_cooldown()


func _compute_damage(attacker: EntityCombat, target: EntityCombat) -> int:
	var profile := attacker.player_profile if attacker.is_player else {}
	if attacker.is_player:
		var class_id := str(profile.get("class", "warrior"))
		var skill := CombatDamage.skill_for_class(class_id, profile)
		var atk_dict := {
			"weapon_attack": int(profile.get("weapon_attack", 0)),
			"skill": skill,
			"class": class_id,
			"level": int(profile.get("level", 1)),
		}
		return CombatDamage.compute(atk_dict, target.defense, config)
	var mob_def: Dictionary = _monster_defs.get(attacker.mob_id, {})
	var atk_dict_mob := {
		"weapon_attack": int(mob_def.get("attack", 1)),
		"skill": 0,
		"class": "warrior",
		"level": 1,
	}
	return CombatDamage.compute(atk_dict_mob, 0 if target.is_player else target.defense, config)


func _grant_kill_rewards(mob_id: String) -> void:
	var def: Dictionary = _monster_defs.get(mob_id, {})
	_player_xp += int(def.get("xp", 0))
	var gold: Dictionary = def.get("gold", {})
	var lo := int(gold.get("min", 0))
	var hi := int(gold.get("max", lo))
	_player_gold += _rng.random_int(lo, hi)
