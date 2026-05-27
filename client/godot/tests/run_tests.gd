extends SceneTree
## Entry point: godot --headless --path client/godot -s res://tests/run_tests.gd


func _initialize() -> void:
	var suite := preload("res://tests/unit/test_tick_world.gd").new()
	var failures: int = suite.run()
	if failures > 0:
		push_error("%d test assertion(s) failed" % failures)
		quit(1)
	else:
		print("All TickWorld tests passed.")
		quit(0)
