extends RefCounted

const GridPathfinder := preload("res://scripts/core/grid_pathfinder.gd")
const GridWalkability := preload("res://scripts/core/grid_walkability.gd")

var _failures: int = 0


func run() -> int:
	_test_path_around_wall()
	_test_no_path_returns_empty()
	return _failures


func _assert_true(c: bool, msg: String) -> void:
	if not c:
		push_error("FAIL: %s" % msg)
		_failures += 1


func _test_path_around_wall() -> void:
	var walk := GridWalkability.new()
	walk.set_map_bounds(Rect2i(0, 0, 10, 10))
	walk.set_blocked(Vector2i(5, 5))
	var path: Array[Vector2i] = GridPathfinder.find_path(walk, Vector2i(4, 5), Vector2i(6, 5))
	_assert_true(path.size() >= 2, "path detours wall")


func _test_no_path_returns_empty() -> void:
	var walk := GridWalkability.new()
	walk.set_map_bounds(Rect2i(0, 0, 5, 5))
	walk.set_blocked(Vector2i(2, 0))
	var path: Array[Vector2i] = GridPathfinder.find_path(walk, Vector2i(0, 0), Vector2i(2, 0))
	_assert_true(path.is_empty(), "blocked goal has no path")
