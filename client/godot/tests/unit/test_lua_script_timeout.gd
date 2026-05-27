extends RefCounted

const LuaScriptRunner := preload("res://scripts/lua/lua_script_runner.gd")
const LuaSandbox := preload("res://scripts/lua/lua_sandbox.gd")
const TickWorld := preload("res://scripts/core/tick_world.gd")

var _failures: int = 0


func run() -> int:
	if not LuaSandbox.is_extension_available():
		push_error("BLOCKED: lua-gdextension not installed")
		return 1
	_test_action_budget_halts()
	return _failures


func _assert_true(c: bool, msg: String) -> void:
	if not c:
		push_error("FAIL: %s" % msg)
		_failures += 1


func _test_action_budget_halts() -> void:
	var world := TickWorld.new()
	var runner := LuaScriptRunner.new()
	runner.setup(world, &"player")
	var src := "function on_tick()\n"
	for i in range(20):
		src += "  move(\"N\")\n"
	src += "end\n"
	runner.load_source(src)
	runner.enabled = true
	runner.on_world_tick()
	_assert_true(runner.timeout_triggered or not runner.enabled, "runaway moves trigger timeout")
