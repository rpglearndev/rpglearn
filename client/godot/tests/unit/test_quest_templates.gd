extends RefCounted

const MvpDataLoader := preload("res://scripts/data/mvp_data_loader.gd")

var _failures: int = 0


func run() -> int:
	_test_templates_by_quest_id()
	return _failures


func _assert_true(c: bool, msg: String) -> void:
	if not c:
		push_error("FAIL: %s" % msg)
		_failures += 1


func _test_templates_by_quest_id() -> void:
	var store = MvpDataLoader.load_all()
	_assert_true(store != null, "store loads")
	var tpl: String = store.get_quest_template("quest_variables_state")
	_assert_true(tpl.contains("getHp"), "variables quest template")
	_assert_true(store.get_quest_template("quest_loop_patrol").contains("for"), "loop template")
	_assert_true(store.get_quest_template("missing").is_empty(), "unknown quest empty")
