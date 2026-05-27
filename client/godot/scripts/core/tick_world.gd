class_name TickWorld
extends RefCounted
## Simulación determinista por ticks. La lógica de juego no usa delta real.

const _GameAction := preload("res://scripts/core/game_action.gd")
const _GridWalkability := preload("res://scripts/core/grid_walkability.gd")


const DEFAULT_TICKS_PER_SECOND := 10

signal tick_processed(tick_index: int)

var ticks_per_second: int = DEFAULT_TICKS_PER_SECOND:
	set(value):
		assert(value > 0, "ticks_per_second must be positive")
		ticks_per_second = value

var tick_index: int = 0
var tick_duration_seconds: float:
	get:
		return 1.0 / float(ticks_per_second)

var _action_queue: Array = []
var _entity_positions: Dictionary = {}
var _walkability = null


func _init(walkability = null) -> void:
	_walkability = walkability if walkability else _GridWalkability.new()


func set_entity_position(entity_id: StringName, cell: Vector2i) -> void:
	_entity_positions[entity_id] = cell


func get_entity_position(entity_id: StringName) -> Vector2i:
	return _entity_positions.get(entity_id, Vector2i.ZERO)


func enqueue_action(action) -> void:
	assert(_GameAction.is_major_type(action.type), "Only major actions can be enqueued")
	_action_queue.append(action)


func pending_action_count() -> int:
	return _action_queue.size()


func clear_action_queue() -> void:
	## Vacía la cola (p. ej. input manual con prioridad sobre script/bot).
	_action_queue.clear()


func step() -> void:
	tick_index += 1
	if _action_queue.is_empty():
		tick_processed.emit(tick_index)
		return
	var action = _action_queue.pop_front()
	_process_major_action(action)
	tick_processed.emit(tick_index)


func step_n(count: int) -> void:
	for _i in count:
		step()


func replay_actions(actions: Array) -> Array[Vector2i]:
	## Ejecuta acciones en orden (una por tick) y devuelve historial de posición del player.
	var history: Array[Vector2i] = []
	var player := &"player"
	for action in actions:
		enqueue_action(action)
		step()
		history.append(get_entity_position(player))
	return history


func _process_major_action(action) -> void:
	match action.type:
		_GameAction.Type.MOVE:
			_apply_move(action.entity_id, action.direction)
		_:
			push_warning("TickWorld: unimplemented action type %s" % action.type)


func _apply_move(entity_id: StringName, direction: Vector2i) -> void:
	if direction not in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		return
	var current: Vector2i = get_entity_position(entity_id)
	var target: Vector2i = current + direction
	if _walkability.is_walkable(target):
		_entity_positions[entity_id] = target
