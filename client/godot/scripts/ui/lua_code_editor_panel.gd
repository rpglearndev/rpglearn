extends CanvasLayer
## Editor Lua in-game: CodeEdit, Run/Stop, consola i18n, plantillas por quest_id (US-031).

const LuaEditorController := preload("res://scripts/ui/lua_editor_controller.gd")
const QuestValidationI18n := preload("res://scripts/quest/quest_validation_i18n.gd")
const LuaCodeEditTheme := preload("res://scripts/ui/lua_code_edit_theme.gd")

signal closed

var controller: LuaEditorController = null

var _backdrop: ColorRect
var _panel: PanelContainer
var _objective: Label
var _code_edit: CodeEdit
var _console_scroll: ScrollContainer
var _console: RichTextLabel
var _quest_select: OptionButton
var _validate_btn: Button
var _run_btn: Button
var _stop_btn: Button
var _override_btn: Button
var _close_btn: Button


func _ready() -> void:
	layer = 10
	_build_ui()
	visible = false
	_validate_btn.pressed.connect(_on_validate_pressed)
	_run_btn.pressed.connect(_on_run_pressed)
	_stop_btn.pressed.connect(_on_stop_pressed)
	_override_btn.pressed.connect(_on_override_pressed)
	_close_btn.pressed.connect(_on_close_pressed)
	_quest_select.item_selected.connect(_on_quest_selected)
	populate_quests()


func bind_controller(ctrl: LuaEditorController) -> void:
	controller = ctrl


func open_editor() -> void:
	if visible:
		return
	visible = true
	_update_objective_label()
	_code_edit.grab_focus()


func close_editor() -> void:
	if visible:
		_on_close_pressed()


func toggle_visible() -> void:
	if visible:
		close_editor()
	else:
		open_editor()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_on_close_pressed()
		get_viewport().set_input_as_handled()


func is_open() -> bool:
	return visible


func get_source() -> String:
	return _code_edit.text


func set_source(text: String) -> void:
	_code_edit.text = text


func clear_console() -> void:
	_console.clear()


func log_console(result: Dictionary) -> void:
	## Mensaje legible (validación u otros) sin prefijo técnico duplicado.
	var text: String = str(result.get("text", ""))
	if text.is_empty():
		return
	_console.append_text(text + "\n")
	_resize_console_width()
	_scroll_console_end()


func _resize_console_width() -> void:
	var w: float = _console_scroll.size.x
	if w > 24.0:
		_console.custom_minimum_size.x = w


func _build_ui() -> void:
	_backdrop = ColorRect.new()
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.05, 0.06, 0.1, 0.82)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_backdrop)

	var center := MarginContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.add_theme_constant_override("margin_left", 24)
	center.add_theme_constant_override("margin_right", 24)
	center.add_theme_constant_override("margin_top", 20)
	center.add_theme_constant_override("margin_bottom", 20)
	_backdrop.add_child(center)

	_panel = PanelContainer.new()
	_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.13, 0.18, 0.98)
	panel_style.border_color = Color(0.45, 0.55, 0.75, 0.9)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(6)
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 12
	panel_style.content_margin_bottom = 12
	_panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "Editor Lua — E abrir · Esc o Cerrar para salir"
	title.add_theme_color_override("font_color", Color(0.92, 0.94, 1.0))
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 6)
	vbox.add_child(toolbar)

	_quest_select = OptionButton.new()
	_quest_select.custom_minimum_size.x = 240
	toolbar.add_child(_quest_select)

	_validate_btn = _make_toolbar_button("Validar")
	_run_btn = _make_toolbar_button("Run")
	_stop_btn = _make_toolbar_button("Stop")
	_override_btn = _make_toolbar_button("Manual")
	_close_btn = _make_toolbar_button("Cerrar")
	for b in [_validate_btn, _run_btn, _stop_btn, _override_btn, _close_btn]:
		toolbar.add_child(b)

	_objective = Label.new()
	_objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objective.add_theme_color_override("font_color", Color(0.75, 0.88, 1.0))
	_objective.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_objective)

	_code_edit = CodeEdit.new()
	_code_edit.custom_minimum_size.y = 120
	_code_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_code_edit.size_flags_stretch_ratio = 0.38
	_code_edit.placeholder_text = "function on_tick()\n  -- tu código\nend"
	_code_edit.gutters_draw_line_numbers = true
	LuaCodeEditTheme.apply(_code_edit)
	vbox.add_child(_code_edit)

	var console_panel := PanelContainer.new()
	console_panel.custom_minimum_size.y = 200
	console_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	console_panel.size_flags_stretch_ratio = 0.48
	var console_style := StyleBoxFlat.new()
	console_style.bg_color = Color(0.06, 0.07, 0.1, 1.0)
	console_style.border_color = Color(0.35, 0.4, 0.5)
	console_style.set_border_width_all(1)
	console_style.set_corner_radius_all(4)
	console_style.content_margin_left = 8
	console_style.content_margin_right = 8
	console_style.content_margin_top = 6
	console_style.content_margin_bottom = 6
	console_panel.add_theme_stylebox_override("panel", console_style)
	vbox.add_child(console_panel)

	_console_scroll = ScrollContainer.new()
	_console_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_console_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_console_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	console_panel.add_child(_console_scroll)

	_console = RichTextLabel.new()
	_console.bbcode_enabled = false
	_console.scroll_active = false
	_console.fit_content = true
	_console.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_console.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_console.add_theme_color_override("default_color", Color(0.95, 0.96, 0.98))
	_console.add_theme_font_size_override("normal_font_size", 14)
	_console_scroll.add_child(_console)


func _make_toolbar_button(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	_style_button(btn)
	return btn


func _style_button(ctrl: Control) -> void:
	if ctrl is Button:
		ctrl.add_theme_color_override("font_color", Color(0.95, 0.96, 1.0))
		ctrl.add_theme_font_size_override("font_size", 14)


func _update_objective_label() -> void:
	var qid := get_selected_quest_id()
	var goal := QuestValidationI18n.goal_for_quest(qid)
	if goal.is_empty():
		_objective.text = "Elige una misión del desplegable. Validar revisa tu código; Run lo ejecuta en el mapa."
	else:
		_objective.text = "Objetivo: %s" % goal


func populate_quests() -> void:
	_quest_select.clear()
	_quest_select.add_item("(elige misión)", -1)
	if not MvpData.is_loaded():
		return
	for quest in MvpData.store.quests:
		if quest is Dictionary and quest.get("mode") == "script":
			_quest_select.add_item(str(quest["id"]))
	_update_objective_label()


func _on_quest_selected(index: int) -> void:
	if index <= 0 or not MvpData.is_loaded():
		_update_objective_label()
		return
	var quest_id: String = _quest_select.get_item_text(index)
	var tpl: String = MvpData.store.get_quest_template(quest_id)
	if not tpl.is_empty():
		_code_edit.text = tpl
	_update_objective_label()


func get_selected_quest_id() -> String:
	var idx := _quest_select.selected
	if idx <= 0:
		return ""
	return _quest_select.get_item_text(idx)


func _on_validate_pressed() -> void:
	if controller == null:
		return
	clear_console()
	log_console(controller.validate_script(get_selected_quest_id(), _code_edit.text))


func _on_run_pressed() -> void:
	if controller == null:
		return
	clear_console()
	var result: Dictionary = controller.run_script(_code_edit.text, get_selected_quest_id())
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


func _scroll_console_end() -> void:
	await get_tree().process_frame
	var vbar := _console_scroll.get_v_scroll_bar()
	if vbar:
		vbar.value = vbar.max_value
