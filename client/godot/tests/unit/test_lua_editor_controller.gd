extends RefCounted

const LuaEditorController := preload("res://scripts/ui/lua_editor_controller.gd")
const LuaScriptRunner := preload("res://scripts/lua/lua_script_runner.gd")
const ManualTickInput := preload("res://scripts/input/manual_tick_input.gd")
const TickWorld := preload("res://scripts/core/tick_world.gd")
const LuaSandbox := preload("res://scripts/lua/lua_sandbox.gd")

var _failures: int = 0


func run() -> int:
	if not LuaSandbox.is_extension_available():
		push_error("BLOCKED: lua-gdextension not installed")
		return 1
	_test_run_stop_override()
	return _failures


func _assert_eq(a, b, msg: String) -> void:
	if a != b:
		push_error("FAIL: %s (%s vs %s)" % [msg, a, b])
		_failures += 1


func _assert_true(c: bool, msg: String) -> void:
	if not c:
		push_error("FAIL: %s" % msg)
		_failures += 1


func _test_run_stop_override() -> void:
	var world := TickWorld.new()
	var manual := ManualTickInput.new()
	var runner := LuaScriptRunner.new()
	runner.setup(world, &"player")
	var ctrl := LuaEditorController.new()
	ctrl.setup(world, &"player", runner, manual)
	_assert_true(not ctrl.is_script_running(), "idle")
	var patrol := "function on_tick()\n  for i = 1, 2 do move(\"N\") end\nend\n"
	var result: Dictionary = ctrl.run_script(patrol)
	_assert_true(result.get("ok", false), "run loads")
	_assert_true(ctrl.is_script_running(), "running after run")
	runner.on_world_tick()
	_assert_true(world.pending_action_count() > 0, "patrol enqueues moves in one on_tick")
	ctrl.stop_script()
	_assert_true(not ctrl.is_script_running(), "stopped")
	_assert_eq(world.pending_action_count(), 0, "stop clears action queue")
	ctrl.run_script("function on_tick() end\n")
	ctrl.enable_manual_override()
	_assert_true(ctrl.is_manual_override(), "override on")
	_assert_true(not ctrl.is_script_running(), "override stops script")
	_assert_true(ctrl.allows_manual_tick(), "manual allowed")
