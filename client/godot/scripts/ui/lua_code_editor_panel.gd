extends CanvasLayer
## Editor Lua acoplado a la derecha: mapa visible, botones con iconos (US-031 UX).

const LuaEditorController := preload("res://scripts/ui/lua_editor_controller.gd")
const QuestValidationI18n := preload("res://scripts/quest/quest_validation_i18n.gd")
const LuaCodeEditTheme := preload("res://scripts/ui/lua_code_edit_theme.gd")
const LuaEditorIcons := preload("res://scripts/ui/lua_editor_icons.gd")

const DOCK_WIDTH := 340

signal closed

var controller: LuaEditorController = null

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
	# Evita que teclas ya pulsadas (WASD) muevan al personaje al abrir.
	if controller != null and controller.manual_input != null:
		controller.manual_input.clear_active(controller.world, controller.entity_id)


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
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(row)

	var passthrough := Control.new()
	passthrough.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	passthrough.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(passthrough)

	var dock_margin := MarginContainer.new()
	dock_margin.mouse_filter = Control.MOUSE_FILTER_STOP
	dock_margin.custom_minimum_size.x = DOCK_WIDTH
	dock_margin.add_theme_constant_override("margin_top", 8)
	dock_margin.add_theme_constant_override("margin_bottom", 8)
	dock_margin.add_theme_constant_override("margin_right", 8)
	row.add_child(dock_margin)

	_panel = PanelContainer.new()
	_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.11, 0.15, 0.94)
	panel_style.border_color = Color(0.4, 0.5, 0.65, 0.85)
	panel_style.set_border_width_all(1)
	panel_style.set_border_width(SIDE_LEFT, 2)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	_panel.add_theme_stylebox_override("panel", panel_style)
	dock_margin.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(vbox)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	vbox.add_child(header)

	var title := Label.new()
	title.text = "Lua"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", Color(0.9, 0.93, 1.0))
	title.add_theme_font_size_override("font_size", 15)
	header.add_child(title)

	_close_btn = _make_icon_button(LuaEditorIcons.close(), "Cerrar (Esc)")
	header.add_child(_close_btn)

	_quest_select = OptionButton.new()
	_quest_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(_quest_select)

	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 4)
	vbox.add_child(toolbar)

	_validate_btn = _make_icon_button(LuaEditorIcons.validate(), "Validar script")
	_run_btn = _make_icon_button(LuaEditorIcons.run(), "Ejecutar (Run)")
	_stop_btn = _make_icon_button(LuaEditorIcons.stop(), "Detener (Stop)")
	_override_btn = _make_icon_button(LuaEditorIcons.manual(), "Control manual (WASD)")
	for b in [_validate_btn, _run_btn, _stop_btn, _override_btn]:
		toolbar.add_child(b)

	_objective = Label.new()
	_objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objective.max_lines_visible = 3
	_objective.add_theme_color_override("font_color", Color(0.7, 0.82, 0.95))
	_objective.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_objective)

	_code_edit = CodeEdit.new()
	_code_edit.custom_minimum_size.y = 100
	_code_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_code_edit.size_flags_stretch_ratio = 1.0
	_code_edit.placeholder_text = "function on_tick()\n  -- tu código\nend"
	_code_edit.gutters_draw_line_numbers = true
	LuaCodeEditTheme.apply(_code_edit)
	vbox.add_child(_code_edit)

	var console_panel := PanelContainer.new()
	console_panel.custom_minimum_size.y = 110
	console_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	var console_style := StyleBoxFlat.new()
	console_style.bg_color = Color(0.06, 0.07, 0.1, 1.0)
	console_style.border_color = Color(0.32, 0.38, 0.48)
	console_style.set_border_width_all(1)
	console_style.set_corner_radius_all(3)
	console_style.content_margin_left = 6
	console_style.content_margin_right = 6
	console_style.content_margin_top = 4
	console_style.content_margin_bottom = 4
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
	_console.add_theme_color_override("default_color", Color(0.92, 0.94, 0.98))
	_console.add_theme_font_size_override("normal_font_size", 12)
	_console_scroll.add_child(_console)


func _make_icon_button(icon_tex: ImageTexture, tooltip: String) -> Button:
	var btn := Button.new()
	btn.icon = icon_tex
	btn.expand_icon = true
	btn.text = ""
	btn.tooltip_text = tooltip
	btn.custom_minimum_size = Vector2(36, 36)
	btn.focus_mode = Control.FOCUS_NONE
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.18, 0.2, 0.28, 0.9)
	normal.set_corner_radius_all(4)
	var hover := normal.duplicate()
	hover.bg_color = Color(0.28, 0.32, 0.42, 0.95)
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.14, 0.16, 0.22, 1.0)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", normal)
	return btn


func _update_objective_label() -> void:
	var qid := get_selected_quest_id()
	var goal := QuestValidationI18n.goal_for_quest(qid)
	if goal.is_empty():
		_objective.text = "E = abrir · Esc = cerrar. Validar / Run / Stop con iconos."
	else:
		_objective.text = goal


func populate_quests() -> void:
	_quest_select.clear()
	_quest_select.add_item("(misión)", -1)
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
