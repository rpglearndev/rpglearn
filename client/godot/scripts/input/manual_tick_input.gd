extends RefCounted
## Input manual por tick: WASD/flechas, mantener tecla = 1 movimiento por tick.
## Prioridad manual: al pulsar tecla se vacía la cola del TickWorld (anula bot/script).

const _GameAction := preload("res://scripts/core/game_action.gd")

var _keyboard_held: Vector2i = Vector2i.ZERO

## Joystick: cardinal expuesto por UI (`VirtualJoystick`) o tests; teclado tiene prioridad si hay tecla pulsada.
var joystick_cardinal: Vector2i = Vector2i.ZERO


func effective_direction() -> Vector2i:
	if _keyboard_held != Vector2i.ZERO:
		return _keyboard_held
	return joystick_cardinal


func handle_key_event(world, entity_id: StringName, event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	var key_event := event as InputEventKey
	if key_event.echo:
		return false
	var dir := _keycode_to_direction(key_event.keycode)
	if dir == Vector2i.ZERO:
		return false
	if key_event.pressed:
		_keyboard_held = dir
		world.clear_action_queue()
		world.enqueue_action(_GameAction.move(entity_id, dir))
	else:
		if _keyboard_held == dir:
			_keyboard_held = Vector2i.ZERO
			world.clear_action_queue()
	return true


func on_tick_processed(world, entity_id: StringName) -> void:
	var dir := effective_direction()
	if dir != Vector2i.ZERO:
		world.enqueue_action(_GameAction.move(entity_id, dir))


func set_joystick_cardinal(world, entity_id: StringName, cardinal: Vector2i) -> void:
	## UI del joystick: al cambiar dirección o soltar, prioridad manual (cola).
	if cardinal == joystick_cardinal:
		return
	joystick_cardinal = cardinal
	if cardinal == Vector2i.ZERO:
		world.clear_action_queue()
		return
	world.clear_action_queue()
	world.enqueue_action(_GameAction.move(entity_id, cardinal))


static func _keycode_to_direction(keycode: int) -> Vector2i:
	match keycode:
		KEY_W, KEY_UP:
			return Vector2i.UP
		KEY_S, KEY_DOWN:
			return Vector2i.DOWN
		KEY_A, KEY_LEFT:
			return Vector2i.LEFT
		KEY_D, KEY_RIGHT:
			return Vector2i.RIGHT
	return Vector2i.ZERO
