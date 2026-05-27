extends Node
## Autoload: runner global del tick world (debug / juego).

var world: TickWorld = TickWorld.new()
var _runner: TickWorldRunner


func _ready() -> void:
	_runner = TickWorldRunner.new()
	_runner.world = world
	add_child(_runner)


func enqueue_move(direction: Vector2i, entity_id: StringName = &"player") -> void:
	world.enqueue_action(GameAction.move(entity_id, direction))
