extends RefCounted
## Tests US-090 — carga JSON desde data/mvp.

const MvpDataLoader := preload("res://scripts/data/mvp_data_loader.gd")

var _failures: int = 0


func run() -> int:
	_test_loads_all_files()
	_test_monster_power_order()
	_test_shop_and_quests()
	_test_spawns_world_01()
	return _failures


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: %s" % message)
		_failures += 1


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		push_error("FAIL: %s (expected %s, got %s)" % [message, expected, actual])
		_failures += 1


func _test_loads_all_files() -> void:
	var store = MvpDataLoader.load_all()
	_assert_true(store != null, "store loads")
	_assert_true(store.monsters.size() >= 3, "monsters present")
	_assert_true(store.items.size() >= 8, "items present")
	_assert_eq(store.quests.size(), 10, "ten tutorial quests")
	_assert_true(store.shops.has("shop_riverton_trader"), "riverton shop")


func _test_monster_power_order() -> void:
	var store = MvpDataLoader.load_all()
	var slime: Dictionary = store.get_monster("mob_slime")
	var wolf: Dictionary = store.get_monster("mob_wolf")
	var bandit: Dictionary = store.get_monster("mob_bandit")
	_assert_true(slime["hp"] < wolf["hp"], "slime hp < wolf")
	_assert_true(wolf["hp"] < bandit["hp"], "wolf hp < bandit")
	_assert_true(slime["attack"] < wolf["attack"], "slime atk < wolf")
	_assert_true(wolf["attack"] < bandit["attack"], "wolf atk < bandit")


func _test_shop_and_quests() -> void:
	var store = MvpDataLoader.load_all()
	var shop: Dictionary = store.get_shop("shop_riverton_trader")
	var buy_ids: Array = []
	for row in shop.get("buy", []):
		buy_ids.append(row["item_id"])
	_assert_true("pot_hp_small" in buy_ids, "shop sells hp potion")
	_assert_true("pot_mp_small" in buy_ids, "shop sells mp potion")
	var first: Dictionary = store.quests[0]
	_assert_eq(first["id"], "quest_welcome_manual", "quests ordered")


func _test_spawns_world_01() -> void:
	var store = MvpDataLoader.load_all()
	_assert_eq(store.map_id, "world_01", "spawns map id")
	_assert_true(store.spawns.size() >= 3, "spawns defined")
	var has_slime := false
	for s in store.spawns:
		if s.get("mob_id") == "mob_slime":
			has_slime = true
	_assert_true(has_slime, "slime spawn exists")
