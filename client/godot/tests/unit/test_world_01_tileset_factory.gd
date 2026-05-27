extends RefCounted

const World01TilesetFactory := preload("res://scripts/world/world_01_tileset_factory.gd")
const World01Layout := preload("res://scripts/world/world_01_layout.gd")
const WorldZoneMap := preload("res://scripts/world/world_zone_map.gd")

var _failures: int = 0


func run() -> int:
	_test_tile_size_and_nearest()
	_test_layout_walkability()
	_test_practice_gate_is_open()
	return _failures


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: %s" % message)
		_failures += 1


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		push_error("FAIL: %s (expected %s, got %s)" % [message, expected, actual])
		_failures += 1


func _test_tile_size_and_nearest() -> void:
	_assert_true(World01TilesetFactory.mixel_textures_available(), "mixel atlases under res://assets/mixel")
	var tile_set := World01TilesetFactory.create_tile_set()
	_assert_eq(tile_set.tile_size, Vector2i(32, 32), "tile size 32")
	_assert_eq(tile_set.get_source_count(), 5, "ground + rocks + ruins + details + trees")
	_assert_true(World01TilesetFactory.project_uses_nearest_texture_filter(), "nearest via project setting")


func _test_layout_walkability() -> void:
	_assert_true(not World01Layout.is_walkable_tile(World01Layout.TileKind.FENCE), "fence blocked")
	_assert_true(World01Layout.is_walkable_tile(World01Layout.TileKind.GRASS), "grass walkable")


func _test_practice_gate_is_open() -> void:
	var gate := WorldZoneMap.PRACTICE_GATE
	var grid: Array = World01Layout.build_tile_grid()
	var kind: int = grid[gate.y][gate.x]
	_assert_eq(kind, World01Layout.TileKind.GRASS, "practice gate is grass not fence")
	_assert_true(World01Layout.is_walkable_tile(kind), "practice gate walkable")
