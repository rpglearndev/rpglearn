class_name MvpDataPaths
extends RefCounted

const DATA_ROOT := "res://data/mvp/"

const MONSTERS := DATA_ROOT + "monsters.json"
const ITEMS := DATA_ROOT + "items.json"
const QUESTS := DATA_ROOT + "quests.json"
const SHOP := DATA_ROOT + "shop.json"
const SPAWNS := DATA_ROOT + "spawns.json"
const QUEST_TEMPLATES := DATA_ROOT + "quest_templates.json"


static func all_json_paths() -> PackedStringArray:
	return PackedStringArray([MONSTERS, ITEMS, QUESTS, SHOP, SPAWNS, QUEST_TEMPLATES])


static func global_path(res_path: String) -> String:
	return ProjectSettings.globalize_path(res_path)


static func files_available() -> bool:
	for path in all_json_paths():
		if not FileAccess.file_exists(global_path(path)):
			return false
	return true
