extends Node
## Autoload: runner global del tick world (debug / juego).

const _TickWorld := preload("res://scripts/core/tick_world.gd")
const _TickWorldRunner := preload("res://scripts/core/tick_world_runner.gd")
const _GameAction := preload("res://scripts/core/game_action.gd")

var world = null
var _runner = null


func _ready() -> void:
	world = _TickWorld.new()
	_runner = _TickWorldRunner.new()
	_runner.world = world
	add_child(_runner)


func enqueue_move(direction: Vector2i, entity_id: StringName = &"player") -> void:
	world.enqueue_action(_GameAction.move(entity_id, direction))
