extends RefCounted

const LuaSandbox := preload("res://scripts/lua/lua_sandbox.gd")
const LuaApiBridge := preload("res://scripts/lua/lua_api_bridge.gd")
const LuaApiRegistry := preload("res://scripts/lua/lua_api_registry.gd")
const TickWorld := preload("res://scripts/core/tick_world.gd")

var _failures: int = 0


func run() -> int:
	if not LuaSandbox.is_extension_available():
		push_error("BLOCKED: lua-gdextension not installed (run scripts/setup_lua_gdextension.ps1)")
		return 1
	_test_syntax_error_fails()
	_test_move_to_no_path()
	_test_get_position_dot_access()
	return _failures


func _assert_true(c: bool, msg: String) -> void:
	if not c:
		push_error("FAIL: %s" % msg)
		_failures += 1


func _test_syntax_error_fails() -> void:
	var world := TickWorld.new()
	var bridge := LuaApiBridge.new(world)
	var sandbox := LuaSandbox.new()
	var allowed: Array[String] = ["getTick", "move"]
	_assert_true(not sandbox.load_script("function on_tick( end", allowed, bridge), "syntax error")


func _test_move_to_no_path() -> void:
	var world := TickWorld.new()
	world.get_walkability().set_map_bounds(Rect2i(0, 0, 20, 20))
	world.get_walkability().set_blocked(Vector2i(10, 10))
	world.set_entity_position(&"player", Vector2i(0, 0))
	var bridge := LuaApiBridge.new(world)
	var sandbox := LuaSandbox.new()
	var allowed: Array[String] = LuaApiRegistry.BASE_READS + LuaApiRegistry.BASE_ACTIONS
	sandbox.load_script(
		"function on_tick()\n  moveTo(10, 10)\nend\n",
		allowed,
		bridge
	)
	sandbox.call_on_tick()
	_assert_true(not bridge.was_last_move_to_ok(), "moveTo on blocked tile fails")


func _test_get_position_dot_access() -> void:
	var world := TickWorld.new()
	world.set_entity_position(&"player", Vector2i(5, 7))
	var bridge := LuaApiBridge.new(world)
	var sandbox := LuaSandbox.new()
	var allowed: Array[String] = ["getPosition"]
	var src := "function on_tick()\n  local p = getPosition()\n  if p.x ~= 5 or p.y ~= 7 then error('bad pos') end\nend\n"
	_assert_true(sandbox.load_script(src, allowed, bridge), "load getPosition script")
	_assert_true(sandbox.call_on_tick(), "getPosition().x/.y in Lua")
