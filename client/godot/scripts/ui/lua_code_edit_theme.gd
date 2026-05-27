class_name LuaCodeEditTheme
extends RefCounted
## Colores legibles para CodeEdit (fondo oscuro). API Godot 4.6 CodeHighlighter.


static func apply(code_edit: CodeEdit) -> void:
	code_edit.add_theme_color_override("font_color", Color(0.95, 0.96, 0.98))
	code_edit.add_theme_color_override("background_color", Color(0.08, 0.09, 0.12))
	code_edit.add_theme_color_override("caret_color", Color(1.0, 1.0, 1.0))
	code_edit.add_theme_color_override("selection_color", Color(0.28, 0.45, 0.7, 0.5))
	code_edit.add_theme_color_override("line_number_color", Color(0.55, 0.6, 0.72))
	code_edit.add_theme_color_override("bookmark_color", Color(0.6, 0.75, 1.0))
	code_edit.highlight_current_line = true
	code_edit.add_theme_color_override("current_line_color", Color(0.15, 0.18, 0.26, 0.85))
	var hl := CodeHighlighter.new()
	var bright := Color(0.92, 0.94, 0.98)
	hl.number_color = Color(0.82, 0.95, 0.78)
	hl.symbol_color = bright
	hl.function_color = Color(0.78, 0.9, 1.0)
	hl.member_variable_color = Color(0.82, 0.92, 1.0)
	var kw := Color(0.95, 0.8, 0.98)
	for word in [
		"function", "local", "if", "then", "else", "elseif", "end",
		"and", "or", "not", "return", "true", "false", "nil",
		"while", "do", "for", "in", "break", "repeat", "until",
	]:
		hl.add_keyword_color(word, kw)
	hl.add_color_region("--", "", Color(0.58, 0.65, 0.75), true)
	hl.add_color_region("\"", "\"", Color(0.85, 0.95, 0.72))
	hl.add_color_region("'", "'", Color(0.85, 0.95, 0.72))
	code_edit.syntax_highlighter = hl
