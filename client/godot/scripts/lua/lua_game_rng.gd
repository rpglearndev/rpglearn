class_name LuaGameRng
extends RefCounted
## RNG determinista del motor (única fuente permitida en retos).

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func set_seed(seed_value: int) -> void:
	_rng.seed = seed_value


func random() -> float:
	return _rng.randf()


func random_int(min_value: int, max_value: int) -> int:
	return _rng.randi_range(min_value, max_value)
