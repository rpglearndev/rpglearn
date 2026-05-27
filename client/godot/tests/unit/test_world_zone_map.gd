extends RefCounted
## Tests WorldZoneMap (US-012).

const WorldZoneMap := preload("res://scripts/world/world_zone_map.gd")
const WorldZone := preload("res://scripts/world/world_zone.gd")

var _failures: int = 0


func run() -> int:
	_test_zone_at_cell()
	_test_practice_area_inside_greenfield()
	_test_practice_perimeter_not_inside()
	return _failures


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		push_error("FAIL: %s (expected %s, got %s)" % [message, expected, actual])
		_failures += 1


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: %s" % message)
		_failures += 1


func _test_zone_at_cell() -> void:
	var zones := WorldZoneMap.new()
	_assert_eq(zones.get_zone(Vector2i(5, 5)), WorldZone.Id.GREENFIELD, "greenfield west")
	_assert_eq(zones.get_zone(Vector2i(25, 10)), WorldZone.Id.RIVERTON, "riverton center")
	_assert_eq(zones.get_zone(Vector2i(40, 15)), WorldZone.Id.OUTSKIRTS, "outskirts east")


func _test_practice_area_inside_greenfield() -> void:
	var zones := WorldZoneMap.new()
	var inside := Vector2i(8, 8)
	_assert_true(zones.is_practice_area(inside), "practice interior")
	_assert_eq(zones.get_zone(inside), WorldZone.Id.GREENFIELD, "practice still greenfield zone")


func _test_practice_perimeter_not_inside() -> void:
	var zones := WorldZoneMap.new()
	_assert_true(not zones.is_practice_area(Vector2i(4, 8)), "on fence column")
	_assert_true(not zones.is_practice_area(Vector2i(20, 8)), "outside practice in riverton")
