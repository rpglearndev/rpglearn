class_name MvpDataLoader
extends RefCounted

const MvpDataPaths := preload("res://scripts/data/mvp_data_paths.gd")
const MvpDataStore := preload("res://scripts/data/mvp_data_store.gd")


static func load_all() -> MvpDataStore:
	if not MvpDataPaths.files_available():
		push_error("MvpDataLoader: missing JSON under res://data/mvp/ (run scripts/link_mvp_data.ps1)")
		return null
	var store := MvpDataStore.new()
	if not _load_monsters(store):
		return null
	if not _load_items(store):
		return null
	if not _load_quests(store):
		return null
	if not _load_shops(store):
		return null
	if not _load_spawns(store):
		return null
	if not _load_quest_templates(store):
		return null
	if not _load_combat(store):
		return null
	return store


static func _read_json(res_path: String) -> Variant:
	var file_path := MvpDataPaths.global_path(res_path)
	var text := FileAccess.get_file_as_string(file_path)
	if text.is_empty():
		push_error("MvpDataLoader: empty or missing %s" % res_path)
		return null
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("MvpDataLoader: invalid JSON %s" % res_path)
		return null
	return parsed


static func _load_monsters(store: MvpDataStore) -> bool:
	var root: Variant = _read_json(MvpDataPaths.MONSTERS)
	if root == null or not root is Dictionary:
		return false
	for row in root.get("monsters", []):
		if row is Dictionary and row.has("id"):
			store.monsters[row["id"]] = row
	return true


static func _load_items(store: MvpDataStore) -> bool:
	var root: Variant = _read_json(MvpDataPaths.ITEMS)
	if root == null or not root is Dictionary:
		return false
	for row in root.get("items", []):
		if row is Dictionary and row.has("id"):
			store.items[row["id"]] = row
	return true


static func _load_quests(store: MvpDataStore) -> bool:
	var root: Variant = _read_json(MvpDataPaths.QUESTS)
	if root == null or not root is Dictionary:
		return false
	var rows: Array = root.get("quests", [])
	rows.sort_custom(func(a, b): return int(a.get("order", 0)) < int(b.get("order", 0)))
	store.quests = rows
	for row in rows:
		if row is Dictionary and row.has("id"):
			store.quests_by_id[row["id"]] = row
	return true


static func _load_shops(store: MvpDataStore) -> bool:
	var root: Variant = _read_json(MvpDataPaths.SHOP)
	if root == null or not root is Dictionary:
		return false
	for row in root.get("shops", []):
		if row is Dictionary and row.has("id"):
			store.shops[row["id"]] = row
	return true


static func _load_spawns(store: MvpDataStore) -> bool:
	var root: Variant = _read_json(MvpDataPaths.SPAWNS)
	if root == null or not root is Dictionary:
		return false
	store.map_id = str(root.get("map_id", ""))
	store.spawns = root.get("spawns", [])
	return true


static func _load_combat(store: MvpDataStore) -> bool:
	var root: Variant = _read_json(MvpDataPaths.COMBAT)
	if root == null or not root is Dictionary:
		return false
	store.combat = root
	return true


static func _load_quest_templates(store: MvpDataStore) -> bool:
	var root: Variant = _read_json(MvpDataPaths.QUEST_TEMPLATES)
	if root == null or not root is Dictionary:
		return false
	for row in root.get("templates", []):
		if row is Dictionary and row.has("quest_id"):
			store.quest_templates[str(row["quest_id"])] = str(row.get("template", ""))
	return true
