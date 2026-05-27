extends Control
## Escena debug US-010: muestra tick index y posición (sin depender de delta en lógica).

const _TickWorld := preload("res://scripts/core/tick_world.gd")
const _TickWorldRunner := preload("res://scripts/core/tick_world_runner.gd")
const _GameAction := preload("res://scripts/core/game_action.gd")

var world = null
var _runner = null

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
	_refresh()


func _refresh() -> void:
	var pos := world.get_entity_position(&"player")
	_label.text = "Tick: %d | TPS: %d | Player: (%d, %d)\nWASD = encolar movimiento" % [
		world.tick_index,
		world.ticks_per_second,
		pos.x,
		pos.y,
	]


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var dir := Vector2i.ZERO
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
	world.enqueue_action(_GameAction.move(&"player", dir))
	get_viewport().set_input_as_handled()
