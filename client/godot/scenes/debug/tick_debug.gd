extends Control
## Escena debug US-010: muestra tick index y posición (sin depender de delta en lógica).

const _TickWorld := preload("res://scripts/core/tick_world.gd")
const _TickWorldRunner := preload("res://scripts/core/tick_world_runner.gd")
const _GameAction := preload("res://scripts/core/game_action.gd")

var world = null
var _runner = null
var _held_dir: Vector2i = Vector2i.ZERO

@onready var _label: Label = $VBox/InfoLabel


func _ready() -> void:
	world = _TickWorld.new()
	world.set_entity_position(&"player", Vector2i(10, 10))
	world.tick_processed.connect(_on_tick_processed)
	_runner = _TickWorldRunner.new()
	_runner.world = world
	add_child(_runner)
	_refresh()


func _on_tick_processed(_tick_index: int) -> void:
	if _held_dir != Vector2i.ZERO:
		world.enqueue_action(_GameAction.move(&"player", _held_dir))
	_refresh()


func _refresh() -> void:
	var pos: Vector2i = world.get_entity_position(&"player")
	_label.text = "Tick: %d | TPS: %d | Player: (%d, %d)\nWASD = encolar movimiento" % [
		world.tick_index,
		world.ticks_per_second,
		pos.x,
		pos.y,
	]


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or event.echo:
		return
	var dir: Vector2i = Vector2i.ZERO
	match event.keycode:
		KEY_W, KEY_UP:
			dir = Vector2i.UP
		KEY_S, KEY_DOWN:
			dir = Vector2i.DOWN
		KEY_A, KEY_LEFT:
			dir = Vector2i.LEFT
		KEY_D, KEY_RIGHT:
			dir = Vector2i.RIGHT
		_:
			return
	if dir == Vector2i.ZERO:
		return
	if event.pressed:
		_held_dir = dir
	else:
		if _held_dir == dir:
			_held_dir = Vector2i.ZERO
	get_viewport().set_input_as_handled()
