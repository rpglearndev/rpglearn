class_name LuaSandbox
extends RefCounted
## Runtime Lua sandbox (lua-gdextension). Sin os/io/package.

const LuaApiRegistry := preload("res://scripts/lua/lua_api_registry.gd")
const LuaApiBridge := preload("res://scripts/lua/lua_api_bridge.gd")

const SAFE_LIBS := 1 | 8 | 32 | 64  # LUA_BASE | STRING | MATH | TABLE

const MAX_INSTRUCTIONS_PER_CALL := 10000

var _state = null
var _loaded: bool = false
var _last_error: Dictionary = {}


static func is_extension_available() -> bool:
	return ClassDB.class_exists("LuaState")


func load_script(source: String, allowed: Array[String], bridge: LuaApiBridge) -> bool:
	_last_error = {}
	if not is_extension_available():
		_last_error = {"message": "LuaState extension missing (run scripts/setup_lua_gdextension.ps1)", "line": 0}
		return false
	_state = ClassDB.instantiate("LuaState")
	_state.open_libraries(SAFE_LIBS)
	_bind_api(allowed, bridge)
	var chunk_name := "@player_script"
	var result = _state.do_string(source, chunk_name)
	if _is_lua_error(result):
		_capture_error(result)
		_loaded = false
		return false
	_loaded = true
	return true


func call_on_tick() -> bool:
	if not _loaded or _state == null:
		return false
	_last_error = {}
	var result = _state.do_string("if type(on_tick) == 'function' then on_tick() end", "@on_tick")
	if _is_lua_error(result):
		_capture_error(result)
		return false
	return true


func get_last_error() -> Dictionary:
	return _last_error


func _bind_api(allowed: Array[String], bridge: LuaApiBridge) -> void:
	var callables: Dictionary = bridge.build_callables(allowed)
	for api_name in callables:
		if api_name == "getPosition":
			var inner: Callable = callables[api_name]
			_state.globals[api_name] = func():
				var cell: Vector2i = inner.call()
				return _state.create_table({"x": cell.x, "y": cell.y})
		else:
			_state.globals[api_name] = callables[api_name]
	_state.globals["game"] = _state.create_table({
		"random": callables.get("game_random"),
		"random_int": callables.get("game_random_int"),
	})


static func _is_lua_error(result) -> bool:
	return result != null and str(result.get_class()) == "LuaError"


func _capture_error(err) -> void:
	_last_error = {
		"message": str(err.message),
		"line": _parse_line_from_message(str(err.message)),
	}


static func _parse_line_from_message(msg: String) -> int:
	var re := RegEx.new()
	re.compile(":(\\d+):")
	var found := re.search(msg)
	if found:
		return int(found.get_string(1))
	return 0
