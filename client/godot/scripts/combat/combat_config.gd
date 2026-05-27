class_name CombatConfig
extends RefCounted

var melee_range: int = 1
var max_desired_range: int = 6
var attack_cooldown_ticks: int = 1
var min_damage: int = 1
var formula: Dictionary = {}
var player_defaults: Dictionary = {}


static func from_dict(data: Dictionary) -> CombatConfig:
	var cfg := CombatConfig.new()
	cfg.melee_range = int(data.get("melee_range", 1))
	cfg.max_desired_range = int(data.get("max_desired_range", 6))
	cfg.attack_cooldown_ticks = int(data.get("attack_cooldown_ticks", 1))
	cfg.min_damage = int(data.get("min_damage", 1))
	cfg.formula = data.get("formula", {})
	cfg.player_defaults = data.get("player_defaults", {})
	return cfg
