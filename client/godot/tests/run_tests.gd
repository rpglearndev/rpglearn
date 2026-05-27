extends SceneTree
## Entry point: godot --headless --path client/godot -s res://tests/run_tests.gd


func _initialize() -> void:
	var total_failures := 0
	total_failures += _run_suite("res://tests/unit/test_tick_world.gd", "TickWorld")
	total_failures += _run_suite("res://tests/unit/test_manual_tick_input.gd", "ManualTickInput")
	if total_failures > 0:
		push_error("%d test assertion(s) failed (all suites)" % total_failures)
		quit(1)
	else:
		print("All tests passed (TickWorld + ManualTickInput).")
		quit(0)


func _run_suite(path: String, name: String) -> int:
	var suite_script: GDScript = load(path) as GDScript
	if suite_script == null:
		push_error("Failed to load suite: %s" % path)
		return 1
	var suite = suite_script.new()
	var failures: int = suite.run()
	if failures > 0:
		push_error("%s: %d failure(s)" % [name, failures])
	return failures
