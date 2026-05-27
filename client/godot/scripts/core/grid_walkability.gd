class_name GridWalkability
extends RefCounted
## Mapa walkable por tiles; usado por TickWorld (sin dependencia de escena).


var _blocked: Dictionary = {}


func set_blocked(cell: Vector2i, blocked: bool = true) -> void:
	if blocked:
		_blocked[cell] = true
	else:
		_blocked.erase(cell)


func is_walkable(cell: Vector2i) -> bool:
	return not _blocked.has(cell)
