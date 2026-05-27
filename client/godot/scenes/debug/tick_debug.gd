extends Control
## Escena debug: tick + input manual (US-010 + US-011).

const _TickWorld := preload("res://scripts/core/tick_world.gd")
const _TickWorldRunner := preload("res://scripts/core/tick_world_runner.gd")
const _ManualTickInput := preload("res://scripts/input/manual_tick_input.gd")

var world = null
var _runner = null
var _manual_input = null

@onready var _label: Label = $VBox/InfoLabel
@onready var _joystick: Control = $VirtualJoystick


func _ready() -> void:
	world = _TickWorld.new()
	_manual_input = _ManualTickInput.new()
	world.set_entity_position(&"player", Vector2i(10, 10))
	world.tick_processed.connect(_on_tick_processed)
	if _joystick.has_signal("cardinal_changed"):
		_joystick.cardinal_changed.connect(_on_joystick_cardinal)
	_runner = _TickWorldRunner.new()
	_runner.world = world
	add_child(_runner)
	_refresh()


func _on_joystick_cardinal(dir: Vector2i) -> void:
	_manual_input.set_joystick_cardinal(world, &"player", dir)


func _on_tick_processed(_tick_index: int) -> void:
	_manual_input.on_tick_processed(world, &"player")
	_refresh()


func _refresh() -> void:
	var pos: Vector2i = world.get_entity_position(&"player")
	_label.text = "Tick: %d | TPS: %d | Player: (%d, %d)\nWASD = 1 tile (mantén = 1/tick)\nJoystick = abajo-izquierda (ratón/touch)" % [
		world.tick_index,
		world.ticks_per_second,
		pos.x,
		pos.y,
	]


func _unhandled_key_input(event: InputEvent) -> void:
	if _manual_input.handle_key_event(world, &"player", event):
		get_viewport().set_input_as_handled()
