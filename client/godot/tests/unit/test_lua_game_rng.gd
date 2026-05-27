extends RefCounted

const LuaGameRng := preload("res://scripts/lua/lua_game_rng.gd")

var _failures: int = 0


func run() -> int:
	_test_same_seed_same_sequence()
	return _failures


func _assert_eq(a, b, msg: String) -> void:
	if a != b:
		push_error("FAIL: %s (%s vs %s)" % [msg, a, b])
		_failures += 1


func _test_same_seed_same_sequence() -> void:
	var a := LuaGameRng.new()
	var b := LuaGameRng.new()
	a.set_seed(12345)
	b.set_seed(12345)
	_assert_eq(a.random(), b.random(), "rng deterministic with seed")
