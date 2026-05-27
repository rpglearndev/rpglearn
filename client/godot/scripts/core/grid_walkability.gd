class_name GridWalkability
extends RefCounted
## Mapa walkable por tiles; usado por TickWorld (sin dependencia de escena).


var _blocked: Dictionary = {}
var _map_bounds: Rect2i = Rect2i()
var _use_map_bounds: bool = false


func set_map_bounds(bounds: Rect2i) -> void:
	_map_bounds = bounds
	_use_map_bounds = true


func set_blocked(cell: Vector2i, blocked: bool = true) -> void:
	if blocked:
		_blocked[cell] = true
	else:
		_blocked.erase(cell)


func is_walkable(cell: Vector2i) -> bool:
	if _use_map_bounds and not _map_bounds.has_point(cell):
		return false
	return not _blocked.has(cell)
