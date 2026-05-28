extends RefCounted
## US-021 — monsters.json, spawns, drops y poder.

const MvpDataLoader := preload("res://scripts/data/mvp_data_loader.gd")
const MobSpriteLoader := preload("res://scripts/world/mob_sprite_loader.gd")

var _failures: int = 0


func run() -> int:
	_test_three_mvp_mobs_defined()
	_test_power_order()
	_test_spawns_reference_valid_mobs()
	_test_spawn_zones_progression()
	_test_drops_reference_items()
	_test_mob_sprites_distinct()
	return _failures


func _assert_true(c: bool, msg: String) -> void:
	if not c:
		push_error("FAIL: %s" % msg)
		_failures += 1


func _assert_eq(a, b, msg: String) -> void:
	if a != b:
		push_error("FAIL: %s (expected %s, got %s)" % [msg, b, a])
		_failures += 1


func _test_three_mvp_mobs_defined() -> void:
	var store = MvpDataLoader.load_all()
	for id in ["mob_slime", "mob_wolf", "mob_bandit"]:
		_assert_true(store.get_monster(id).has("id"), "monster %s exists" % id)


func _test_power_order() -> void:
	var store = MvpDataLoader.load_all()
	var slime: Dictionary = store.get_monster("mob_slime")
	var wolf: Dictionary = store.get_monster("mob_wolf")
	var bandit: Dictionary = store.get_monster("mob_bandit")
	_assert_true(int(slime["hp"]) < int(wolf["hp"]), "slime hp < wolf")
	_assert_true(int(wolf["hp"]) < int(bandit["hp"]), "wolf hp < bandit")
	_assert_true(int(slime["attack"]) < int(wolf["attack"]), "slime atk < wolf")
	_assert_true(int(wolf["attack"]) < int(bandit["attack"]), "wolf atk < bandit")


func _test_spawns_reference_valid_mobs() -> void:
	var store = MvpDataLoader.load_all()
	_assert_eq(store.map_id, "world_01", "spawns map")
	_assert_true(store.spawns.size() >= 5, "five spawns")
	for row in store.spawns:
		var mob_id := str(row.get("mob_id", ""))
		_assert_true(not store.get_monster(mob_id).is_empty(), "spawn mob %s in json" % mob_id)


func _test_spawn_zones_progression() -> void:
	var store = MvpDataLoader.load_all()
	var slime_zones: Array = []
	var wolf_zones: Array = []
	for row in store.spawns:
		match str(row.get("mob_id")):
			"mob_slime":
				slime_zones.append(str(row.get("zone")))
			"mob_wolf":
				wolf_zones.append(str(row.get("zone")))
	_assert_true("greenfield" in slime_zones, "slimes in greenfield")
	_assert_true("outskirts" in wolf_zones, "wolves in outskirts")


func _test_drops_reference_items() -> void:
	var store = MvpDataLoader.load_all()
	for mob_id in ["mob_slime", "mob_wolf", "mob_bandit"]:
		var def: Dictionary = store.get_monster(mob_id)
		for drop in def.get("drops", []):
			var item_id := str(drop.get("item_id", ""))
			_assert_true(not store.get_item(item_id).is_empty(), "%s drop %s exists" % [mob_id, item_id])
		var gold: Dictionary = def.get("gold", {})
		_assert_true(int(gold.get("max", 0)) >= int(gold.get("min", 0)), "%s gold range" % mob_id)


func _test_mob_sprites_distinct() -> void:
	var a: Image = MobSpriteLoader.texture_for("mob_slime").get_image()
	var b: Image = MobSpriteLoader.texture_for("mob_wolf").get_image()
	var c: Image = MobSpriteLoader.texture_for("mob_bandit").get_image()
	_assert_true(not _images_equal(a, b), "slime != wolf sprite")
	_assert_true(not _images_equal(a, c), "slime != bandit sprite")


static func _images_equal(a: Image, b: Image) -> bool:
	if a.get_width() != b.get_width() or a.get_height() != b.get_height():
		return false
	for y in a.get_height():
		for x in a.get_width():
			if a.get_pixel(x, y) != b.get_pixel(x, y):
				return false
	return true
