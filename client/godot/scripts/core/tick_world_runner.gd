class_name TickWorldRunner
extends Node
## Acumula tiempo real solo para disparar ticks; la simulación vive en TickWorld.step().

const _TickWorld := preload("res://scripts/core/tick_world.gd")

@export var world = null

var _accumulator: float = 0.0


func _ready() -> void:
	if world == null:
		world = _TickWorld.new()


func _process(delta: float) -> void:
	_accumulator += delta
	var tick_duration: float = world.tick_duration_seconds
	while _accumulator >= tick_duration:
		world.step()
		_accumulator -= tick_duration


func reset_accumulator() -> void:
	_accumulator = 0.0
