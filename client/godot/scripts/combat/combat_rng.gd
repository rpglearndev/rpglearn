class_name CombatRng
extends RefCounted
## RNG determinista para oro de loot de combate (misma semilla → mismos rolls).

var _state: int = 1


func seed(value: int) -> void:
	_state = value if value != 0 else 1


func random_int(min_v: int, max_v: int) -> int:
	if max_v < min_v:
		return min_v
	_state = (_state * 1103515245 + 12345) & 0x7FFFFFFF
	var span := max_v - min_v + 1
	return min_v + (_state % span)
