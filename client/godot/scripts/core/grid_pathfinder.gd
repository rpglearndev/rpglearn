class_name GridPathfinder
extends RefCounted
## A* sobre grid 4-dir (misma semántica que TickWorld.move).

const _DIRS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


static func find_path(walkability, from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	if from_cell == to_cell:
		return []
	if walkability == null or not walkability.is_walkable(to_cell):
		return []
	var open: Array[Vector2i] = [from_cell]
	var came_from: Dictionary = {}
	var g_score: Dictionary = {from_cell: 0}
	var f_score: Dictionary = {from_cell: _heuristic(from_cell, to_cell)}

	while not open.is_empty():
		var current := _pop_lowest_f(open, f_score)
		if current == to_cell:
			return _reconstruct(came_from, current)
		for dir in _DIRS:
			var neighbor: Vector2i = current + dir
			if not walkability.is_walkable(neighbor):
				continue
			var tentative: int = g_score.get(current, 999999) + 1
			if tentative < g_score.get(neighbor, 999999):
				came_from[neighbor] = current
				g_score[neighbor] = tentative
				f_score[neighbor] = tentative + _heuristic(neighbor, to_cell)
				if neighbor not in open:
					open.append(neighbor)
	return []


static func _heuristic(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


static func _pop_lowest_f(open: Array[Vector2i], f_score: Dictionary) -> Vector2i:
	var best_idx := 0
	var best_f: int = f_score.get(open[0], 999999)
	for i in range(1, open.size()):
		var f: int = f_score.get(open[i], 999999)
		if f < best_f:
			best_f = f
			best_idx = i
	var cell: Vector2i = open[best_idx]
	open.remove_at(best_idx)
	return cell


static func _reconstruct(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	while came_from.has(current):
		path.push_front(current)
		current = came_from[current]
	return path
