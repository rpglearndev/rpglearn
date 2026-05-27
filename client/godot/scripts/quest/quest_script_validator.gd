class_name QuestScriptValidator
extends RefCounted
## Análisis estático del script Lua por quest_id (misiones tutorial 2–5).

const QuestValidationI18n := preload("res://scripts/quest/quest_validation_i18n.gd")

const VALIDATED_QUESTS: Array[String] = [
	"quest_variables_state",
	"quest_if_safe_or_heal",
	"quest_loop_patrol",
	"quest_function_move_to_flag",
]


static func validate(quest_id: String, source: String, locale: String = "es") -> Dictionary:
	if quest_id not in VALIDATED_QUESTS:
		return _ok()
	var src := _strip_comments(source)
	match quest_id:
		"quest_variables_state":
			return _validate_variables(src, locale)
		"quest_if_safe_or_heal":
			return _validate_if_else(src, locale)
		"quest_loop_patrol":
			return _validate_loop(src, locale)
		"quest_function_move_to_flag":
			return _validate_function(src, locale)
	return _ok()


static func _validate_variables(src: String, locale: String) -> Dictionary:
	if not _matches(src, "local\\s+hp\\s*="):
		return _fail("quest.validation.variables.missing_local_hp", "quest.validation.hint.variables", "quest.validation.example.variables", locale)
	if not _matches(src, "local\\s+mana\\s*="):
		return _fail("quest.validation.variables.missing_local_mana", "quest.validation.hint.variables", "quest.validation.example.variables", locale)
	if not _matches(src, "getPosition\\s*\\("):
		return _fail("quest.validation.variables.missing_get_position", "quest.validation.hint.variables", "quest.validation.example.variables", locale)
	if not _matches(src, "pos\\.([xy])|pos\\s*\\[\\s*[\"'](x|y)[\"']\\s*\\]"):
		return _fail("quest.validation.variables.missing_pos_use", "quest.validation.hint.variables", "quest.validation.example.variables", locale)
	return _ok()


static func _validate_if_else(src: String, locale: String) -> Dictionary:
	if not _matches(src, "\\bif\\b"):
		return _fail("quest.validation.if.missing_if", "quest.validation.hint.if", "quest.validation.example.if", locale)
	if not _matches(src, "\\belse\\b"):
		return _fail("quest.validation.if.missing_else", "quest.validation.hint.if", "quest.validation.example.if", locale)
	return _ok()


static func _validate_loop(src: String, locale: String) -> Dictionary:
	if _matches(src, "while\\s+true\\s+do"):
		return _fail("quest.validation.loop.infinite_while", "quest.validation.hint.loop", "quest.validation.example.loop", locale)
	var has_for := _matches(src, "\\bfor\\b.+\\bdo\\b")
	var has_while := _matches(src, "\\bwhile\\b.+\\bdo\\b")
	if not has_for and not has_while:
		return _fail("quest.validation.loop.missing_loop", "quest.validation.hint.loop", "quest.validation.example.loop", locale)
	return _ok()


static func _validate_function(src: String, locale: String) -> Dictionary:
	if not _matches(src, "function\\s+[A-Za-z_][A-Za-z0-9_]*\\s*\\("):
		return _fail("quest.validation.function.missing_def", "quest.validation.hint.function", "quest.validation.example.function", locale)
	if not _has_custom_function_call(src):
		return _fail("quest.validation.function.missing_call", "quest.validation.hint.function", "quest.validation.example.function", locale)
	return _ok()


static func _has_custom_function_call(src: String) -> bool:
	var builtins := [
		"getTick", "getPosition", "getHp", "getMana", "getMaxHp", "getMaxMana",
		"getLevel", "getClass", "getSkills", "getCapacity", "getCarryWeight",
		"getInventory", "nearestEnemy", "nearestLoot", "isTileWalkable", "distanceTo",
		"move", "moveTo", "attack", "usePotion", "loot", "equip", "unequip",
		"buy", "sell", "setDesiredRange", "print", "type", "pairs", "ipairs",
		"on_tick", "tonumber", "tostring",
	]
	var re := RegEx.new()
	re.compile("([A-Za-z_][A-Za-z0-9_]*)\\s*\\(")
	var pos := 0
	while true:
		var found := re.search(src, pos)
		if found == null:
			return false
		var name := found.get_string(1)
		if name not in builtins:
			return true
		pos = found.get_end()
	return false


static func _strip_comments(source: String) -> String:
	var lines: PackedStringArray = []
	for line in source.split("\n"):
		var idx := line.find("--")
		if idx >= 0:
			line = line.substr(0, idx)
		lines.append(line)
	return "\n".join(lines)


static func _matches(src: String, pattern: String) -> bool:
	var re := RegEx.new()
	if re.compile(pattern) != OK:
		return false
	return re.search(src) != null


static func _ok() -> Dictionary:
	return {"passed": true}


static func _fail(missing_key: String, hint_key: String, example_key: String, locale: String) -> Dictionary:
	return {
		"passed": false,
		"missing_key": missing_key,
		"hint_key": hint_key,
		"example_key": example_key,
		"missing_text": QuestValidationI18n.translate(missing_key, locale),
		"hint_text": QuestValidationI18n.translate(hint_key, locale),
		"example_text": QuestValidationI18n.translate(example_key, locale),
	}
