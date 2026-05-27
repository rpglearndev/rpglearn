extends CanvasLayer
## Editor Lua in-game: CodeEdit, Run/Stop, consola i18n, plantillas por quest_id (US-031).

const LuaEditorController := preload("res://scripts/ui/lua_editor_controller.gd")

signal closed

var controller: LuaEditorController = null

var _panel: PanelContainer
var _code_edit: CodeEdit
var _console: RichTextLabel
var _quest_select: OptionButton
var _run_btn: Button
var _stop_btn: Button
var _override_btn: Button
var _close_btn: Button


func _ready() -> void:
	layer = 10
	_build_ui()
	visible = false
	_run_btn.pressed.connect(_on_run_pressed)
	_stop_btn.pressed.connect(_on_stop_pressed)
	_override_btn.pressed.connect(_on_override_pressed)
	_close_btn.pressed.connect(_on_close_pressed)
	_quest_select.item_selected.connect(_on_quest_selected)
	populate_quests()


func bind_controller(ctrl: LuaEditorController) -> void:
	controller = ctrl


func toggle_visible() -> void:
	visible = not visible
	if visible:
		_code_edit.grab_focus()


func is_open() -> bool:
	return visible


func get_source() -> String:
	return _code_edit.text


func set_source(text: String) -> void:
	_code_edit.text = text


func clear_console() -> void:
	_console.text = ""


func log_console(result: Dictionary) -> void:
	var key: String = str(result.get("key", ""))
	var text: String = str(result.get("text", ""))
	if key.is_empty():
		_append_line(text)
	else:
		_append_line("[%s] %s" % [key, text])


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(vbox)

	var toolbar := HBoxContainer.new()
	vbox.add_child(toolbar)

	_quest_select = OptionButton.new()
	_quest_select.custom_minimum_size.x = 220
	toolbar.add_child(_quest_select)

	_run_btn = Button.new()
	_run_btn.text = "Run"
	toolbar.add_child(_run_btn)

	_stop_btn = Button.new()
	_stop_btn.text = "Stop"
	toolbar.add_child(_stop_btn)

	_override_btn = Button.new()
	_override_btn.text = "Manual"
	toolbar.add_child(_override_btn)

	_close_btn = Button.new()
	_close_btn.text = "Cerrar"
	toolbar.add_child(_close_btn)

	_code_edit = CodeEdit.new()
	_code_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_code_edit.placeholder_text = "function on_tick()\n  -- tu código\nend"
	_code_edit.gutters_draw_line_numbers = true
	_code_edit.syntax_highlighter = CodeHighlighter.new()
	vbox.add_child(_code_edit)

	_console = RichTextLabel.new()
	_console.custom_minimum_size.y = 100
	_console.scroll_active = true
	_console.fit_content = true
	_console.bbcode_enabled = false
	vbox.add_child(_console)


func populate_quests() -> void:
	_quest_select.clear()
	_quest_select.add_item("(plantilla)", -1)
	if not MvpData.is_loaded():
		return
	for quest in MvpData.store.quests:
		if quest is Dictionary and quest.get("mode") == "script":
			_quest_select.add_item(str(quest["id"]))


func _on_quest_selected(index: int) -> void:
	if index <= 0 or not MvpData.is_loaded():
		return
	var quest_id: String = _quest_select.get_item_text(index)
	var tpl: String = MvpData.store.get_quest_template(quest_id)
	if not tpl.is_empty():
		_code_edit.text = tpl


func _on_run_pressed() -> void:
	if controller == null:
		return
	clear_console()
	var result: Dictionary = controller.run_script(_code_edit.text)
	log_console(result)


func _on_stop_pressed() -> void:
	if controller == null:
		return
	log_console(controller.stop_script())


func _on_override_pressed() -> void:
	if controller == null:
		return
	log_console(controller.enable_manual_override())


func _on_close_pressed() -> void:
	visible = false
	closed.emit()


func _append_line(line: String) -> void:
	if _console.text.is_empty():
		_console.text = line
	else:
		_console.text += "\n" + line
