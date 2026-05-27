extends RefCounted

const QuestScriptValidator := preload("res://scripts/quest/quest_script_validator.gd")

var _failures: int = 0


func run() -> int:
	_test_variables_pass_and_fail()
	_test_if_pass_and_fail()
	_test_loop_infinite()
	_test_function_pass()
	_test_unknown_quest_skips()
	return _failures


func _assert_true(c: bool, msg: String) -> void:
	if not c:
		push_error("FAIL: %s" % msg)
		_failures += 1


func _test_variables_pass_and_fail() -> void:
	var good := """
function on_tick()
  local hp = getHp()
  local mana = getMana()
  local pos = getPosition()
  local x = pos.x
end
"""
	var r: Dictionary = QuestScriptValidator.validate("quest_variables_state", good)
	_assert_true(r["passed"], "variables pass")
	var bad := "function on_tick()\n  move(\"N\")\nend\n"
	r = QuestScriptValidator.validate("quest_variables_state", bad)
	_assert_true(not r["passed"], "variables fail")
	_assert_true(str(r["missing_key"]).begins_with("quest.validation."), "has missing key")


func _test_if_pass_and_fail() -> void:
	var good := "function on_tick()\n  if getHp() < 50 then\n    usePotion()\n  else\n    move(\"N\")\n  end\nend\n"
	_assert_true(QuestScriptValidator.validate("quest_if_safe_or_heal", good)["passed"], "if pass")
	var bad := "function on_tick()\n  if getHp() < 50 then\n    usePotion()\n  end\nend\n"
	_assert_true(not QuestScriptValidator.validate("quest_if_safe_or_heal", bad)["passed"], "if missing else")


func _test_loop_infinite() -> void:
	var bad := "function on_tick()\n  while true do\n    move(\"N\")\n  end\nend\n"
	var r: Dictionary = QuestScriptValidator.validate("quest_loop_patrol", bad)
	_assert_true(not r["passed"], "while true fails")
	_assert_true(r["missing_key"] == "quest.validation.loop.infinite_while", "infinite key")


func _test_function_pass() -> void:
	var good := """
function goToFlag(x, y)
  moveTo(x, y)
end
function on_tick()
  goToFlag(12, 8)
end
"""
	_assert_true(QuestScriptValidator.validate("quest_function_move_to_flag", good)["passed"], "function pass")


func _test_unknown_quest_skips() -> void:
	_assert_true(QuestScriptValidator.validate("quest_shop_loop", "x")["passed"], "unvalidated quest passes")
