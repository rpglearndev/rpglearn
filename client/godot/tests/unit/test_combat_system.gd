extends RefCounted

const TickWorld := preload("res://scripts/core/tick_world.gd")
const GameAction := preload("res://scripts/core/game_action.gd")
const CombatConfig := preload("res://scripts/combat/combat_config.gd")
const CombatSystem := preload("res://scripts/combat/combat_system.gd")
const MvpDataLoader := preload("res://scripts/data/mvp_data_loader.gd")

var _failures: int = 0


func run() -> int:
	_test_melee_range_adjacent_only()
	_test_melee_hits_diagonal_tile()
	_test_ranged_desired_range()
	_test_kill_grants_xp_and_gold()
	_test_cooldown_after_attack()
	return _failures


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: %s" % message)
		_failures += 1


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		push_error("FAIL: %s (expected %s, got %s)" % [message, expected, actual])
		_failures += 1


func _make_world_with_combat() -> Dictionary:
	var store = MvpDataLoader.load_all()
	var cfg := CombatConfig.from_dict(store.combat)
	var world := TickWorld.new()
	var combat := CombatSystem.new()
	combat.setup(world, cfg, store.monsters)
	combat.set_rng_seed(99)
	combat.register_player(&"player")
	world.combat = combat
	return {"world": world, "combat": combat, "store": store}


func _test_melee_range_adjacent_only() -> void:
	var ctx := _make_world_with_combat()
	var world: TickWorld = ctx["world"]
	var combat: CombatSystem = ctx["combat"]
	world.set_entity_position(&"player", Vector2i(5, 5))
	combat.register_monster(&"mob_0", "mob_slime")
	world.set_entity_position(&"mob_0", Vector2i(7, 5))
	_assert_true(not combat.can_attack(&"player", &"mob_0"), "too far for melee")
	world.set_entity_position(&"mob_0", Vector2i(6, 5))
	_assert_true(combat.can_attack(&"player", &"mob_0"), "adjacent melee ok")


func _test_melee_hits_diagonal_tile() -> void:
	var ctx := _make_world_with_combat()
	var world: TickWorld = ctx["world"]
	var combat: CombatSystem = ctx["combat"]
	world.set_entity_position(&"player", Vector2i(15, 17))
	combat.register_monster(&"mob_0", "mob_slime")
	world.set_entity_position(&"mob_0", Vector2i(16, 18))
	_assert_true(combat.can_attack(&"player", &"mob_0"), "diagonal adjacent counts as melee range 1")


func _test_ranged_desired_range() -> void:
	var ctx := _make_world_with_combat()
	var world: TickWorld = ctx["world"]
	var combat: CombatSystem = ctx["combat"]
	combat.set_player_class("archer")
	combat.set_desired_range(3)
	world.set_entity_position(&"player", Vector2i(0, 0))
	combat.register_monster(&"mob_0", "mob_slime")
	world.set_entity_position(&"mob_0", Vector2i(3, 0))
	_assert_true(combat.can_attack(&"player", &"mob_0"), "archer range 3")
	world.set_entity_position(&"mob_0", Vector2i(4, 0))
	_assert_true(not combat.can_attack(&"player", &"mob_0"), "beyond desired range")


func _test_kill_grants_xp_and_gold() -> void:
	var ctx := _make_world_with_combat()
	var world: TickWorld = ctx["world"]
	var combat: CombatSystem = ctx["combat"]
	world.set_entity_position(&"player", Vector2i(1, 1))
	combat.register_monster(&"mob_0", "mob_slime")
	world.set_entity_position(&"mob_0", Vector2i(2, 1))
	while combat.get_hp(&"mob_0") > 0:
		world.enqueue_action(GameAction.attack(&"player", &"mob_0"))
		world.step()
	_assert_eq(combat.get_hp(&"mob_0"), 0, "slime dead")
	_assert_eq(combat.get_player_xp(), 12, "slime xp from json")
	_assert_true(combat.get_player_gold() >= 1, "gold granted")


func _test_cooldown_after_attack() -> void:
	var ctx := _make_world_with_combat()
	var world: TickWorld = ctx["world"]
	var combat: CombatSystem = ctx["combat"]
	world.set_entity_position(&"player", Vector2i(0, 0))
	combat.register_monster(&"mob_0", "mob_bandit")
	world.set_entity_position(&"mob_0", Vector2i(1, 0))
	var result: Dictionary = combat.process_attack(&"player", &"mob_0")
	_assert_true(result.get("ok", false), "attack ok")
	_assert_true(not combat.can_attack(&"player", &"mob_0"), "cooldown active")
