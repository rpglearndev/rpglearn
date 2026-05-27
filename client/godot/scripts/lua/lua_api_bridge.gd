class_name LuaApiBridge
extends RefCounted
## Puente TickWorld ↔ API Lua (callables registrados en el sandbox).

const GameAction := preload("res://scripts/core/game_action.gd")
const GridPathfinder := preload("res://scripts/core/grid_pathfinder.gd")
const LuaGameRng := preload("res://scripts/lua/lua_game_rng.gd")

const DIR_MAP := {
	"N": Vector2i.UP, "S": Vector2i.DOWN, "E": Vector2i.RIGHT, "W": Vector2i.LEFT,
	"UP": Vector2i.UP, "DOWN": Vector2i.DOWN, "LEFT": Vector2i.LEFT, "RIGHT": Vector2i.RIGHT,
}

var world = null
var entity_id: StringName = &"player"
var rng: LuaGameRng = null
var _path_queue: Array[Vector2i] = []
var _last_move_to_ok: bool = true


func _init(p_world, p_entity_id: StringName = &"player") -> void:
	world = p_world
	entity_id = p_entity_id
	rng = LuaGameRng.new()


func build_callables(allowed: Array[String]) -> Dictionary:
	var out: Dictionary = {}
	for name in allowed:
		out[name] = _make_callable(name)
	return out


func consume_path_step() -> void:
	if _path_queue.is_empty():
		return
	var next_cell: Vector2i = _path_queue.pop_front()
	var current: Vector2i = world.get_entity_position(entity_id)
	var delta: Vector2i = next_cell - current
	if delta in DIR_MAP.values():
		world.enqueue_action(GameAction.move(entity_id, delta))


func has_pending_path() -> bool:
	return not _path_queue.is_empty()


func clear_pending() -> void:
	_path_queue.clear()


func was_last_move_to_ok() -> bool:
	return _last_move_to_ok


func _make_callable(name: String) -> Callable:
	match name:
		"getTick":
			return Callable(self, "_get_tick")
		"getPosition":
			return Callable(self, "_get_position")
		"getHp", "getMana", "getMaxHp", "getMaxMana", "getLevel", "getClass":
			return Callable(self, "_stub_number").bind(name)
		"getSkills", "getInventory":
			return Callable(self, "_stub_table")
		"getCapacity", "getCarryWeight":
			return Callable(self, "_stub_number").bind(name)
		"nearestEnemy", "nearestLoot":
			return Callable(self, "_stub_nil")
		"isTileWalkable":
			return Callable(self, "_is_tile_walkable")
		"distanceTo":
			return Callable(self, "_distance_to")
		"move":
			return Callable(self, "_move")
		"moveTo":
			return Callable(self, "_move_to")
		"game_random":
			return Callable(self, "_game_random")
		"game_random_int":
			return Callable(self, "_game_random_int")
		_:
			return Callable(self, "_stub_nil")


func _get_tick() -> int:
	return world.tick_index


func _get_position() -> Vector2i:
	## Vector2i en Lua admite pos.x / pos.y; Dictionary queda como Variant opaco.
	return world.get_entity_position(entity_id)


func _stub_number(_name: String) -> int:
	return 0


func _stub_table() -> Dictionary:
	return {}


func _stub_nil(_a = null, _b = null) -> Variant:
	return null


func _is_tile_walkable(x: int, y: int) -> bool:
	return world.get_walkability().is_walkable(Vector2i(x, y))


func _distance_to(x: int, y: int) -> int:
	var c: Vector2i = world.get_entity_position(entity_id)
	return absi(c.x - x) + absi(c.y - y)


func _move(dir_name: String) -> void:
	var dir: Vector2i = DIR_MAP.get(dir_name.to_upper(), Vector2i.ZERO)
	if dir != Vector2i.ZERO:
		world.enqueue_action(GameAction.move(entity_id, dir))


func _move_to(x: int, y: int) -> bool:
	var from: Vector2i = world.get_entity_position(entity_id)
	var to := Vector2i(x, y)
	var path: Array[Vector2i] = GridPathfinder.find_path(world.get_walkability(), from, to)
	_last_move_to_ok = not path.is_empty() or from == to
	_path_queue = path.duplicate()
	return _last_move_to_ok


func _game_random() -> float:
	return rng.random()


func _game_random_int(min_v: int, max_v: int) -> int:
	return rng.random_int(min_v, max_v)
