extends RefCounted
## Tests ManualTickInput + clear_queue (US-011).

const TickWorld := preload("res://scripts/core/tick_world.gd")
const GameAction := preload("res://scripts/core/game_action.gd")
const ManualTickInput := preload("res://scripts/input/manual_tick_input.gd")

var _failures: int = 0


func run() -> int:
	_test_key_press_clears_bot_queue_and_moves()
	_test_hold_one_tile_per_tick()
	_test_joystick_stub_when_no_keyboard_hold()
	_test_joystick_clears_bot_queue()
	return _failures


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		push_error("FAIL: %s (expected %s, got %s)" % [message, expected, actual])
		_failures += 1


func _key(code: int, pressed: bool) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = pressed
	e.echo = false
	return e


func _test_key_press_clears_bot_queue_and_moves() -> void:
	var world := TickWorld.new()
	world.set_entity_position(&"player", Vector2i(5, 5))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	var manual := ManualTickInput.new()
	var ate := manual.handle_key_event(world, &"player", _key(KEY_W, true))
	_assert_eq(ate, true, "W consumed")
	_assert_eq(world.pending_action_count(), 1, "bot queue cleared; one manual move")
	world.step()
	_assert_eq(world.get_entity_position(&"player"), Vector2i(5, 4), "moved north one tile")


func _test_hold_one_tile_per_tick() -> void:
	var world := TickWorld.new()
	world.set_entity_position(&"player", Vector2i(10, 10))
	var manual := ManualTickInput.new()
	_assert_eq(manual.handle_key_event(world, &"player", _key(KEY_D, true)), true, "D down")
	_simulate_tick(world, manual)
	_assert_eq(world.get_entity_position(&"player"), Vector2i(11, 10), "first tick")
	_simulate_tick(world, manual)
	_assert_eq(world.get_entity_position(&"player"), Vector2i(12, 10), "hold tick 2")
	_simulate_tick(world, manual)
	_assert_eq(world.get_entity_position(&"player"), Vector2i(13, 10), "hold tick 3")
	_assert_eq(manual.handle_key_event(world, &"player", _key(KEY_D, false)), true, "D up")
	_simulate_tick(world, manual)
	_assert_eq(world.get_entity_position(&"player"), Vector2i(13, 10), "no move after release")


func _simulate_tick(world, manual) -> void:
	world.step()
	manual.on_tick_processed(world, &"player")


func _test_joystick_stub_when_no_keyboard_hold() -> void:
	var world := TickWorld.new()
	world.set_entity_position(&"player", Vector2i(0, 0))
	var manual := ManualTickInput.new()
	manual.set_joystick_cardinal(world, &"player", Vector2i.DOWN)
	_simulate_tick(world, manual)
	_assert_eq(world.get_entity_position(&"player"), Vector2i(0, 1), "joystick: first tick moves")
	_simulate_tick(world, manual)
	_assert_eq(world.get_entity_position(&"player"), Vector2i(0, 2), "joystick hold")
	_simulate_tick(world, manual)
	_assert_eq(world.get_entity_position(&"player"), Vector2i(0, 3), "joystick continued")
	manual.set_joystick_cardinal(world, &"player", Vector2i.ZERO)
	_simulate_tick(world, manual)
	_assert_eq(world.get_entity_position(&"player"), Vector2i(0, 3), "release clears stick intent")


func _test_joystick_clears_bot_queue() -> void:
	var world := TickWorld.new()
	world.set_entity_position(&"player", Vector2i(2, 2))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	world.enqueue_action(GameAction.move(&"player", Vector2i.RIGHT))
	var manual := ManualTickInput.new()
	manual.set_joystick_cardinal(world, &"player", Vector2i.UP)
	_assert_eq(world.pending_action_count(), 1, "joystick clears bot queue")
	world.step()
	_assert_eq(world.get_entity_position(&"player"), Vector2i(2, 1), "stick direction applied")
