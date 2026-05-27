class_name MvpDataStore
extends RefCounted
## Datos MVP parseados (monsters, items, quests, shop, spawns).

var monsters: Dictionary = {}
var items: Dictionary = {}
var quests: Array = []
var quests_by_id: Dictionary = {}
var shops: Dictionary = {}
var spawns: Array = []
var map_id: String = ""
var quest_templates: Dictionary = {}


func get_monster(id: String) -> Dictionary:
	return monsters.get(id, {})


func get_item(id: String) -> Dictionary:
	return items.get(id, {})


func get_quest(id: String) -> Dictionary:
	return quests_by_id.get(id, {})


func get_shop(id: String) -> Dictionary:
	return shops.get(id, {})


func get_quest_template(quest_id: String) -> String:
	return str(quest_templates.get(quest_id, ""))
