extends RefCounted

const LuaApiRegistry := preload("res://scripts/lua/lua_api_registry.gd")
const MvpDataLoader := preload("res://scripts/data/mvp_data_loader.gd")

var _failures: int = 0


func run() -> int:
	_test_unlock_includes_move_after_quests()
	return _failures


func _assert_true(c: bool, msg: String) -> void:
	if not c:
		push_error("FAIL: %s" % msg)
		_failures += 1


func _test_unlock_includes_move_after_quests() -> void:
	var store = MvpDataLoader.load_all()
	if store == null:
		push_error("FAIL: mvp data not loaded")
		_failures += 1
		return
	var allowed: Array[String] = LuaApiRegistry.unlocked_for_tutorial_complete(store)
	_assert_true("move" in allowed, "move unlocked")
	_assert_true("buy" in allowed, "buy unlocked from quest_shop_loop")
