class_name EntityCombat
extends RefCounted

var entity_id: StringName = &""
var mob_id: String = ""
var hp: int = 0
var max_hp: int = 0
var defense: int = 0
var is_player: bool = false
var cooldown_ticks: int = 0
var player_profile: Dictionary = {}


func is_alive() -> bool:
	return hp > 0


func reset_cooldown(ticks: int) -> void:
	cooldown_ticks = ticks


func tick_cooldown() -> void:
	if cooldown_ticks > 0:
		cooldown_ticks -= 1
