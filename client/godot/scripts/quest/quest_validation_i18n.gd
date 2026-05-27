class_name QuestValidationI18n
extends RefCounted
## Textos pedagógicos por check (ES/EN) — keys quest.validation.*

const MESSAGES: Dictionary = {
	"quest.validation.variables.missing_local_hp": {
		"es": "Falta declarar una variable local para HP (ej. local hp = getHp()).",
		"en": "Declare a local variable for HP (e.g. local hp = getHp()).",
	},
	"quest.validation.variables.missing_local_mana": {
		"es": "Falta declarar una variable local para mana.",
		"en": "Declare a local variable for mana.",
	},
	"quest.validation.variables.missing_get_position": {
		"es": "Usa getPosition() para leer la posición del jugador.",
		"en": "Use getPosition() to read the player position.",
	},
	"quest.validation.variables.missing_pos_use": {
		"es": "Usa la posición guardada (pos.x / pos.y).",
		"en": "Use the stored position (pos.x / pos.y).",
	},
	"quest.validation.if.missing_if": {
		"es": "Añade un bloque if ... then.",
		"en": "Add an if ... then block.",
	},
	"quest.validation.if.missing_else": {
		"es": "Añade else para la otra rama.",
		"en": "Add else for the other branch.",
	},
	"quest.validation.loop.missing_loop": {
		"es": "Usa un ciclo for o while acotado.",
		"en": "Use a bounded for or while loop.",
	},
	"quest.validation.loop.infinite_while": {
		"es": "Evita while true sin condición de salida.",
		"en": "Avoid while true without an exit condition.",
	},
	"quest.validation.function.missing_def": {
		"es": "Define una función con function nombre() ... end.",
		"en": "Define a function with function name() ... end.",
	},
	"quest.validation.function.missing_call": {
		"es": "Llama a tu función al menos una vez.",
		"en": "Call your function at least once.",
	},
	"quest.validation.goal.variables": {
		"es": "Guarda HP, mana y posición en variables locales y usa pos.x y pos.y.",
		"en": "Store HP, mana and position in local variables and use pos.x and pos.y.",
	},
	"quest.validation.goal.if": {
		"es": "Usa if/else: una rama si HP bajo, otra si estás a salvo.",
		"en": "Use if/else: one branch when HP is low, another when safe.",
	},
	"quest.validation.goal.loop": {
		"es": "Repite movimientos con un for o while acotado (no while true).",
		"en": "Repeat moves with a bounded for or while (not while true).",
	},
	"quest.validation.goal.function": {
		"es": "Crea una función y llámala desde on_tick (p. ej. ir a una casilla).",
		"en": "Create a function and call it from on_tick (e.g. go to a tile).",
	},
	"quest.validation.hint.variables": {
		"es": "local x = pos.x\nlocal y = pos.y",
		"en": "local x = pos.x\nlocal y = pos.y",
	},
	"quest.validation.hint.if": {
		"es": "if getHp() < 50 then usePotion() else move(\"N\") end",
		"en": "if getHp() < 50 then usePotion() else move(\"N\") end",
	},
	"quest.validation.hint.loop": {
		"es": "for i = 1, 2 do move(\"N\") end",
		"en": "for i = 1, 2 do move(\"N\") end",
	},
	"quest.validation.hint.function": {
		"es": "function goToFlag(x, y) moveTo(x, y) end  luego en on_tick: goToFlag(12, 8)",
		"en": "function goToFlag(x, y) moveTo(x, y) end  then in on_tick: goToFlag(12, 8)",
	},
	"quest.validation.example.variables": {
		"es": "local hp = getHp()\nlocal mana = getMana()\nlocal pos = getPosition()\nlocal x = pos.x\nlocal y = pos.y",
		"en": "local hp = getHp()\nlocal mana = getMana()\nlocal pos = getPosition()\nlocal x = pos.x\nlocal y = pos.y",
	},
	"quest.validation.example.if": {
		"es": "if getHp() < 50 then usePotion() else move(\"N\") end",
		"en": "if getHp() < 50 then usePotion() else move(\"N\") end",
	},
	"quest.validation.example.loop": {
		"es": "for i = 1, 2 do move(\"E\") end",
		"en": "for i = 1, 2 do move(\"E\") end",
	},
	"quest.validation.example.function": {
		"es": "function goToFlag(x, y)\n  moveTo(x, y)\nend",
		"en": "function goToFlag(x, y)\n  moveTo(x, y)\nend",
	},
	"quest.validation.passed": {
		"es": "Validación correcta. Pulsa Run para probar en el mapa.",
		"en": "Validation passed. Press Run to test on the map.",
	},
	"lua.error.runtime.timeout_loop": {
		"es": "El script tardó demasiado o encoló demasiadas acciones (posible bucle).",
		"en": "Script ran too long or queued too many actions (possible loop).",
	},
}


static func goal_for_quest(quest_id: String, locale: String = "es") -> String:
	match quest_id:
		"quest_variables_state":
			return translate("quest.validation.goal.variables", locale)
		"quest_if_safe_or_heal":
			return translate("quest.validation.goal.if", locale)
		"quest_loop_patrol":
			return translate("quest.validation.goal.loop", locale)
		"quest_function_move_to_flag":
			return translate("quest.validation.goal.function", locale)
	return ""


static func translate(key: String, locale: String = "es") -> String:
	var pack: Dictionary = MESSAGES.get(key, {})
	if pack.has(locale):
		return str(pack[locale])
	if pack.has("es"):
		return str(pack["es"])
	return key
