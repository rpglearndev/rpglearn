class_name LuaErrorI18n
extends RefCounted
## Mapea errores Lua crudos a keys i18n + texto ES/EN (MVP hasta US-060).

const MESSAGES: Dictionary = {
	"lua.error.syntax": {
		"es": "Error de sintaxis en el script.",
		"en": "Syntax error in the script.",
	},
	"lua.error.runtime.nil_index": {
		"es": "Intentaste usar un valor que no existe (nil). Revisa variables como pos.",
		"en": "Tried to use a missing (nil) value. Check variables like pos.",
	},
	"lua.error.runtime.generic": {
		"es": "Error al ejecutar el script.",
		"en": "Error while running the script.",
	},
	"lua.error.runtime.timeout_loop": {
		"es": "El script tardó demasiado o encoló demasiadas acciones (posible bucle).",
		"en": "Script ran too long or queued too many actions (possible loop).",
	},
	"lua.error.extension_missing": {
		"es": "Lua no está instalado (setup_lua_gdextension.ps1).",
		"en": "Lua extension missing (run setup_lua_gdextension.ps1).",
	},
	"ui.editor.run_ok": {
		"es": "Script en ejecución.",
		"en": "Script running.",
	},
	"ui.editor.stopped": {
		"es": "Script detenido.",
		"en": "Script stopped.",
	},
	"ui.editor.manual_override": {
		"es": "Control manual activo.",
		"en": "Manual control active.",
	},
}


static func resolve(raw_message: String, locale: String = "es") -> Dictionary:
	var key := _detect_key(raw_message)
	return {
		"key": key,
		"text": translate_key(key, locale),
		"raw": raw_message,
	}


static func translate_key(key: String, locale: String = "es") -> String:
	var pack: Dictionary = MESSAGES.get(key, {})
	if pack.has(locale):
		return str(pack[locale])
	if pack.has("es"):
		return str(pack["es"])
	return key


static func _detect_key(raw: String) -> String:
	var lower := raw.to_lower()
	if "syntax" in lower or "expected" in lower:
		return "lua.error.syntax"
	if "nil value" in lower or "attempt to index" in lower:
		return "lua.error.runtime.nil_index"
	if "extension missing" in lower or "luastate" in lower:
		return "lua.error.extension_missing"
	return "lua.error.runtime.generic"
