extends RefCounted
## Tests unitarios TickWorld (US-010). Ejecutar con run_tests.gd

const TickWorld := preload("res://scripts/core/tick_world.gd")
const GameAction := preload("res://scripts/core/game_action.gd")
const GridWalkability := preload("res://scripts/core/grid_walkability.gd")

var _failures: int = 0


func run() -> int:
	_test_default_tickrate()
	_test_configurable_tickrate()
	_test_move_consumes_one_tick_and_one_tile()
	_test_blocked_tile_does_not_move()
	_test_deterministic_replay()
	_test_empty_tick_advances_index_without_move()
	_test_one_major_action_per_tick()
	_test_clear_action_queue()
	_test_map_bounds_block_move()
	return _failures


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: %s" % message)
		_failures += 1


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		push_error("FAIL: %s (expected %s, got %s)" % [message, expected, actual])
		_failures += 1


func _test_default_tickrate() -> void:
	var world := TickWorld.new()
	_assert_eq(world.ticks_per_second, 10, "default TPS")
	_assert_true(is_equal_approx(world.tick_duration_seconds, 0.1), "tick duration 100ms")


func _test_configurable_tickrate() -> void:
	var world := TickWorld.new()
	world.ticks_per_second = 20
	_assert_eq(world.ticks_per_second, 20, "configurable TPS")
	_assert_true(is_equal_approx(world.tick_duration_seconds, 0.05), "tick duration at 20 TPS")


func _test_move_consumes_one_tick_and_one_tile() -> void:
	var grid := GridWalkability.new()
	var world := TickWorld.new(grid)
	world.set_entity_position(&"player", Vector2i(5, 5))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	_assert_eq(world.tick_index, 0, "tick before step")
	world.step()
	_assert_eq(world.tick_index, 1, "one tick consumed")
	_assert_eq(world.get_entity_position(&"player"), Vector2i(6, 5), "moved one tile east")


func _test_blocked_tile_does_not_move() -> void:
	var grid := GridWalkability.new()
	grid.set_blocked(Vector2i(6, 5))
	var world := TickWorld.new(grid)
	world.set_entity_position(&"player", Vector2i(5, 5))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	world.step()
	_assert_eq(world.get_entity_position(&"player"), Vector2i(5, 5), "blocked tile")


func _test_deterministic_replay() -> void:
	var actions: Array = [
		GameAction.move(&"player", Vector2i.RIGHT),
		GameAction.move(&"player", Vector2i.RIGHT),
		GameAction.move(&"player", Vector2i.DOWN),
		GameAction.move(&"player", Vector2i.LEFT),
	]
	var history_a := _run_sequence(actions)
	var history_b := _run_sequence(actions)
	_assert_eq(history_a, history_b, "same input sequence yields same positions")


func _run_sequence(actions: Array) -> Array[Vector2i]:
	var world := TickWorld.new()
	world.set_entity_position(&"player", Vector2i(0, 0))
	return world.replay_actions(actions)


func _test_empty_tick_advances_index_without_move() -> void:
	var world := TickWorld.new()
	world.set_entity_position(&"player", Vector2i(3, 3))
	world.step()
	_assert_eq(world.tick_index, 1, "tick index advances")
	_assert_eq(world.get_entity_position(&"player"), Vector2i(3, 3), "no move without action")


func _test_one_major_action_per_tick() -> void:
	var world := TickWorld.new()
	world.set_entity_position(&"player", Vector2i(0, 0))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	world.step()
	_assert_eq(world.get_entity_position(&"player"), Vector2i(1, 0), "only first action in tick 1")
	world.step()
	_assert_eq(world.get_entity_position(&"player"), Vector2i(2, 0), "second action in tick 2")
	_assert_eq(world.pending_action_count(), 0, "queue drained")


func _test_map_bounds_block_move() -> void:
	var grid := GridWalkability.new()
	grid.set_map_bounds(Rect2i(0, 0, 3, 3))
	var world := TickWorld.new(grid)
	world.set_entity_position(&"player", Vector2i(2, 0))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	world.step()
	_assert_eq(world.get_entity_position(&"player"), Vector2i(2, 0), "cannot leave map east")


func _test_clear_action_queue() -> void:
	var world := TickWorld.new()
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	world.clear_action_queue()
	_assert_eq(world.pending_action_count(), 0, "queue empty after clear")
	world.step()
	_assert_eq(world.get_entity_position(&"player"), Vector2i(0, 0), "no move after clear")
