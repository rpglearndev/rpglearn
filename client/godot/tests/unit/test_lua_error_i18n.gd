extends RefCounted

const LuaErrorI18n := preload("res://scripts/lua/lua_error_i18n.gd")

var _failures: int = 0


func run() -> int:
	_test_syntax_key()
	_test_nil_index_key()
	return _failures


func _assert_eq(a, b, msg: String) -> void:
	if a != b:
		push_error("FAIL: %s (%s vs %s)" % [msg, a, b])
		_failures += 1


func _test_syntax_key() -> void:
	var r: Dictionary = LuaErrorI18n.resolve("player_script:1: syntax error near 'end'", "es")
	_assert_eq(r["key"], "lua.error.syntax", "syntax maps to key")
	_assert_true(not str(r["text"]).is_empty(), "syntax has text")


func _test_nil_index_key() -> void:
	var r: Dictionary = LuaErrorI18n.resolve("attempt to index a nil value", "en")
	_assert_eq(r["key"], "lua.error.runtime.nil_index", "nil index key")


func _assert_true(c: bool, msg: String) -> void:
	if not c:
		push_error("FAIL: %s" % msg)
		_failures += 1
