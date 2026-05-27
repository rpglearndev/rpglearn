extends SceneTree
## Entry point: godot --headless --path client/godot -s res://tests/run_tests.gd


func _initialize() -> void:
	var total_failures := 0
	total_failures += _run_suite("res://tests/unit/test_tick_world.gd", "TickWorld")
	total_failures += _run_suite("res://tests/unit/test_manual_tick_input.gd", "ManualTickInput")
	total_failures += _run_suite("res://tests/unit/test_world_zone_map.gd", "WorldZoneMap")
	total_failures += _run_suite("res://tests/unit/test_world_01_tileset_factory.gd", "World01Tileset")
	total_failures += _run_suite("res://tests/unit/test_mvp_data_loader.gd", "MvpData")
	total_failures += _run_suite("res://tests/unit/test_grid_pathfinder.gd", "GridPathfinder")
	total_failures += _run_suite("res://tests/unit/test_lua_game_rng.gd", "LuaGameRng")
	total_failures += _run_suite("res://tests/unit/test_lua_api_registry.gd", "LuaApiRegistry")
	total_failures += _run_suite("res://tests/unit/test_lua_sandbox.gd", "LuaSandbox")
	total_failures += _run_suite("res://tests/unit/test_quest_templates.gd", "QuestTemplates")
	total_failures += _run_suite("res://tests/unit/test_lua_error_i18n.gd", "LuaErrorI18n")
	total_failures += _run_suite("res://tests/unit/test_lua_editor_controller.gd", "LuaEditorController")
	total_failures += _run_suite("res://tests/unit/test_quest_script_validator.gd", "QuestScriptValidator")
	total_failures += _run_suite("res://tests/unit/test_lua_script_timeout.gd", "LuaScriptTimeout")
	total_failures += _run_suite("res://tests/unit/test_combat_damage.gd", "CombatDamage")
	total_failures += _run_suite("res://tests/unit/test_combat_system.gd", "CombatSystem")
	if total_failures > 0:
		push_error("%d test assertion(s) failed (all suites)" % total_failures)
		quit(1)
	else:
		print("All tests passed (TickWorld + ManualTickInput + World01 + MvpData + Lua + Editor + Validator + Combat).")
		quit(0)


func _run_suite(path: String, name: String) -> int:
	var suite_script: GDScript = load(path) as GDScript
	if suite_script == null:
		push_error("Failed to load suite: %s" % path)
		return 1
	var suite = suite_script.new()
	if suite == null:
		push_error("Suite failed to instantiate: %s" % path)
		return 1
	if not suite.has_method("run"):
		push_error("Suite missing run(): %s" % path)
		return 1
	var failures: int = suite.run()
	if failures > 0:
		push_error("%s: %d failure(s)" % [name, failures])
	return failures
