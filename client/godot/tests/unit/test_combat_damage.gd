extends RefCounted

const CombatConfig := preload("res://scripts/combat/combat_config.gd")
const CombatDamage := preload("res://scripts/combat/combat_damage.gd")

var _failures: int = 0


func run() -> int:
	_test_formula_from_json_defaults()
	_test_respects_defense_floor()
	return _failures


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		push_error("FAIL: %s (expected %s, got %s)" % [message, expected, actual])
		_failures += 1


func _test_formula_from_json_defaults() -> void:
	var cfg := CombatConfig.from_dict({
		"min_damage": 1,
		"formula": {
			"weapon_base": 0,
			"weapon_scale": 1.0,
			"class_multipliers": {"warrior": 1.0},
			"level_factor_divisor": 100,
		},
	})
	var dmg := CombatDamage.compute(
		{"weapon_attack": 5, "skill": 10, "class": "warrior", "level": 1},
		0,
		cfg,
	)
	_assert_eq(dmg, 15, "weapon 5 + skill 10 * scale, level 1")


func _test_respects_defense_floor() -> void:
	var cfg := CombatConfig.from_dict({"min_damage": 1, "formula": {}})
	var dmg := CombatDamage.compute({"weapon_attack": 1, "skill": 0, "class": "warrior", "level": 1}, 99, cfg)
	_assert_eq(dmg, 1, "min damage floor")
