class_name LuaApiRegistry
extends RefCounted
## Funciones API permitidas según progreso de misiones (quests.json api_unlock).

const MvpDataStore := preload("res://scripts/data/mvp_data_store.gd")

## Lecturas base siempre disponibles en MVP (US-030).
const BASE_READS: Array[String] = [
	"getTick", "getPosition", "getHp", "getMana", "getMaxHp", "getMaxMana",
	"getLevel", "getClass", "getSkills", "getCapacity", "getCarryWeight",
	"getInventory", "nearestEnemy", "nearestLoot", "isTileWalkable", "distanceTo",
]

const BASE_ACTIONS: Array[String] = ["move", "moveTo"]

const ALL_KNOWN: Array[String] = [
	"getTick", "getPosition", "getHp", "getMana", "getMaxHp", "getMaxMana",
	"getLevel", "getClass", "getSkills", "getCapacity", "getCarryWeight",
	"getInventory", "nearestEnemy", "nearestLoot", "isTileWalkable", "distanceTo",
	"move", "moveTo", "attack", "usePotion", "loot", "equip", "unequip",
	"buy", "sell", "setDesiredRange", "game_random", "game_random_int",
]


static func unlocked_for_tutorial_complete(store: MvpDataStore) -> Array[String]:
	var allowed: Dictionary = {}
	for name in BASE_READS:
		allowed[name] = true
	for name in BASE_ACTIONS:
		allowed[name] = true
	allowed["game_random"] = true
	allowed["game_random_int"] = true
	for quest in store.quests:
		if quest is Dictionary:
			for api_name in quest.get("api_unlock", []):
				allowed[str(api_name)] = true
	var out: Array[String] = []
	for name in ALL_KNOWN:
		if allowed.has(name):
			out.append(name)
	out.sort()
	return out


static func is_allowed(name: String, allowed: Array[String]) -> bool:
	return name in allowed
