class_name LuaEditorController
extends RefCounted
## Run/Stop/override manual para el editor Lua (US-031).

const LuaErrorI18n := preload("res://scripts/lua/lua_error_i18n.gd")

var world = null
var entity_id: StringName = &"player"
var runner = null
var manual_input = null
var manual_override: bool = false
var locale: String = "es"
var last_console_key: String = ""


func setup(p_world, p_entity_id: StringName, p_runner, p_manual) -> void:
	world = p_world
	entity_id = p_entity_id
	runner = p_runner
	manual_input = p_manual


func run_script(source: String) -> Dictionary:
	manual_override = false
	last_console_key = ""
	if runner == null:
		return _fail("lua.error.runtime.generic", "runner missing")
	const LuaSandbox := preload("res://scripts/lua/lua_sandbox.gd")
	if not LuaSandbox.is_extension_available():
		return _fail("lua.error.extension_missing", "")
	if not runner.load_source(source):
		var raw: String = runner.get_last_lua_error()
		return _fail_from_raw(raw)
	runner.enabled = true
	manual_input.clear_active(world, entity_id)
	last_console_key = "ui.editor.run_ok"
	return {"ok": true, "key": last_console_key, "text": LuaErrorI18n.translate_key(last_console_key, locale)}


func stop_script() -> Dictionary:
	if runner != null:
		runner.halt()
	last_console_key = "ui.editor.stopped"
	return {"ok": true, "key": last_console_key, "text": LuaErrorI18n.translate_key(last_console_key, locale)}


func enable_manual_override() -> Dictionary:
	manual_override = true
	stop_script()
	last_console_key = "ui.editor.manual_override"
	return {"ok": true, "key": last_console_key, "text": LuaErrorI18n.translate_key(last_console_key, locale)}


func on_script_runtime_error(raw: String) -> Dictionary:
	if runner != null:
		runner.halt()
	manual_override = false
	return _fail_from_raw(raw)


func is_script_running() -> bool:
	return runner != null and runner.enabled and not manual_override


func is_manual_override() -> bool:
	return manual_override


func allows_lua_tick() -> bool:
	return is_script_running()


func allows_manual_tick() -> bool:
	return manual_override or not is_script_running()


func _fail(key: String, raw: String) -> Dictionary:
	last_console_key = key
	var text := LuaErrorI18n.translate_key(key, locale)
	if not raw.is_empty():
		text = "%s\n%s" % [text, raw]
	return {"ok": false, "key": key, "text": text, "raw": raw}


func _fail_from_raw(raw: String) -> Dictionary:
	var resolved := LuaErrorI18n.resolve(raw, locale)
	last_console_key = resolved["key"]
	return {"ok": false, "key": resolved["key"], "text": "%s\n[%s]\n%s" % [resolved["text"], resolved["key"], raw], "raw": raw}
