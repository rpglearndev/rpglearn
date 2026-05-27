class_name WorldCombatBootstrap
extends RefCounted

const CombatConfig := preload("res://scripts/combat/combat_config.gd")
const CombatSystem := preload("res://scripts/combat/combat_system.gd")


static func attach(world, store) -> CombatSystem:
	if store == null or store.combat.is_empty():
		return null
	var cfg := CombatConfig.from_dict(store.combat)
	var combat := CombatSystem.new()
	combat.setup(world, cfg, store.monsters)
	combat.set_rng_seed(42)
	combat.register_player(&"player")
	world.combat = combat
	_spawn_mobs(world, combat, store)
	return combat


static func _spawn_mobs(world, combat: CombatSystem, store) -> void:
	var idx := 0
	for row in store.spawns:
		if not row is Dictionary:
			continue
		var mob_id := str(row.get("mob_id", ""))
		var cell: Dictionary = row.get("cell", {})
		if mob_id.is_empty():
			continue
		var entity_id := StringName("mob_%d" % idx)
		idx += 1
		world.set_entity_position(entity_id, Vector2i(int(cell.get("x", 0)), int(cell.get("y", 0))))
		combat.register_monster(entity_id, mob_id)
