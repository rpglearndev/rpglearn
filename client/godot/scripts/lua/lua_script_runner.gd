class_name LuaScriptRunner
extends RefCounted
## Ejecuta script Lua: 1 llamada on_tick + 1 acción mayor por tick del mundo.

const LuaSandbox := preload("res://scripts/lua/lua_sandbox.gd")
const LuaApiBridge := preload("res://scripts/lua/lua_api_bridge.gd")
const LuaApiRegistry := preload("res://scripts/lua/lua_api_registry.gd")
const MvpDataLoader := preload("res://scripts/data/mvp_data_loader.gd")

var sandbox: LuaSandbox = LuaSandbox.new()
var bridge: LuaApiBridge = null
var enabled: bool = false
var challenge_mode: bool = false


func setup(world, entity_id: StringName = &"player", tutorial_unlock_all: bool = true) -> void:
	bridge = LuaApiBridge.new(world, entity_id)
	var store = MvpDataLoader.load_all()
	var allowed: Array[String] = []
	if store != null and tutorial_unlock_all:
		allowed = LuaApiRegistry.unlocked_for_tutorial_complete(store)
	else:
		allowed = []
		allowed.append_array(LuaApiRegistry.BASE_READS)
		allowed.append_array(LuaApiRegistry.BASE_ACTIONS)
	if challenge_mode:
		bridge.rng.set_seed(42)


func load_source(source: String) -> bool:
	if bridge == null:
		return false
	return sandbox.load_script(source, _resolve_allowed_apis(), bridge)


func get_last_lua_error() -> String:
	var err: Dictionary = sandbox.get_last_error()
	if err.is_empty():
		return ""
	return str(err.get("message", ""))


func _resolve_allowed_apis() -> Array[String]:
	if MvpData.is_loaded():
		return LuaApiRegistry.unlocked_for_tutorial_complete(MvpData.store)
	var store = MvpDataLoader.load_all()
	if store != null:
		return LuaApiRegistry.unlocked_for_tutorial_complete(store)
	var allowed: Array[String] = []
	allowed.append_array(LuaApiRegistry.BASE_READS)
	allowed.append_array(LuaApiRegistry.BASE_ACTIONS)
	allowed.append("game_random")
	allowed.append("game_random_int")
	return allowed


func halt() -> void:
	## Stop inmediato: no más on_tick y vacía movimientos ya encolados.
	enabled = false
	if bridge == null:
		return
	bridge.clear_pending()
	if bridge.world != null:
		bridge.world.clear_action_queue()


func on_world_tick() -> void:
	if not enabled or bridge == null:
		return
	if bridge.has_pending_path():
		bridge.consume_path_step()
		return
	if not sandbox.call_on_tick():
		enabled = false
		return
	if bridge.has_pending_path():
		bridge.consume_path_step()
