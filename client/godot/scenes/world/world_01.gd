extends Node2D
## World_01: Greenfield, Riverton, Outskirts + área de práctica (US-012).

const _TickWorld := preload("res://scripts/core/tick_world.gd")
const _TickWorldRunner := preload("res://scripts/core/tick_world_runner.gd")
const _ManualTickInput := preload("res://scripts/input/manual_tick_input.gd")
const _World01MapBuilder := preload("res://scripts/world/world_01_map_builder.gd")
const _WorldZoneMap := preload("res://scripts/world/world_zone_map.gd")
const _WorldZone := preload("res://scripts/world/world_zone.gd")
const _MixelSpriteLoader := preload("res://scripts/world/mixel_sprite_loader.gd")
const _LuaScriptRunner := preload("res://scripts/lua/lua_script_runner.gd")
const _LuaEditorController := preload("res://scripts/ui/lua_editor_controller.gd")
const _WorldCombatBootstrap := preload("res://scripts/combat/world_combat_bootstrap.gd")
const _MobVisualSpawner := preload("res://scripts/world/mob_visual_spawner.gd")
const TILE_SIZE := 32

@onready var _ground: TileMapLayer = $Ground
@onready var _decor: TileMapLayer = $Decor
@onready var _entities: Node2D = $Entities
@onready var _player: Sprite2D = $Entities/Player
@onready var _camera: Camera2D = $Camera2D
@onready var _hud: Label = $HUD/InfoLabel
@onready var _hud_layer: CanvasLayer = $HUD
@onready var _joystick: Control = $HUD/VirtualJoystick
@onready var _lua_editor = $LuaEditor

var world = null
var _runner = null
var _manual_input = null
var _zone_map = null
var _lua_runner = null
var _editor_ctrl = null
var _mob_visuals = null


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.35, 0.55, 0.28))
	_zone_map = _WorldZoneMap.new()
	var walkability := _World01MapBuilder.apply_to_layer(_ground, _decor)
	world = _TickWorld.new(walkability)
	_manual_input = _ManualTickInput.new()
	world.set_entity_position(&"player", Vector2i(8, 13))
	_mob_visuals = _MobVisualSpawner.new()
	if MvpData.is_loaded():
		_WorldCombatBootstrap.attach(world, MvpData.store)
		_mob_visuals.build(_entities, world, world.combat, TILE_SIZE)
	world.tick_processed.connect(_on_tick_processed)
	_runner = _TickWorldRunner.new()
	_runner.world = world
	add_child(_runner)
	_entities.y_sort_enabled = true
	_player.texture = _load_player_texture()
	_setup_camera_limits()
	_sync_entity_visuals()
	if _joystick.has_signal("cardinal_changed"):
		_joystick.cardinal_changed.connect(_on_joystick_cardinal)
	_lua_runner = _LuaScriptRunner.new()
	_lua_runner.setup(world, &"player")
	_editor_ctrl = _LuaEditorController.new()
	_editor_ctrl.setup(world, &"player", _lua_runner, _manual_input)
	_lua_editor.bind_controller(_editor_ctrl)
	_lua_editor.closed.connect(_on_lua_editor_closed)
	_refresh_hud()


func _on_tick_processed(_tick_index: int) -> void:
	var manual_input_allowed: bool = not _lua_editor.is_open() or _editor_ctrl.is_manual_override()
	var manual_dir := Vector2i.ZERO
	if manual_input_allowed:
		manual_dir = _manual_input.effective_direction()
	if manual_dir != Vector2i.ZERO:
		if _editor_ctrl.is_script_running():
			_editor_ctrl.interrupt_script_for_manual()
		_manual_input.on_tick_processed(world, &"player")
	elif _editor_ctrl.allows_lua_tick():
		_lua_runner.on_world_tick()
		if not _lua_runner.enabled:
			if _lua_runner.timeout_triggered and _lua_editor.is_open():
				_lua_editor.log_console(_editor_ctrl.on_script_runtime_error(""))
			else:
				var raw: String = _lua_runner.get_last_lua_error()
				if not raw.is_empty() and _lua_editor.is_open():
					_lua_editor.log_console(_editor_ctrl.on_script_runtime_error(raw))
	elif _editor_ctrl.allows_manual_tick() and manual_input_allowed:
		_manual_input.on_tick_processed(world, &"player")
	_sync_entity_visuals()
	_refresh_hud()


func _setup_camera_limits() -> void:
	_camera.enabled = true
	_camera.make_current()
	_sync_camera_position()


func _sync_entity_visuals() -> void:
	var cell: Vector2i = world.get_entity_position(&"player")
	_player.position = Vector2(cell.x * TILE_SIZE + TILE_SIZE / 2, cell.y * TILE_SIZE + TILE_SIZE / 2)
	_player.z_index = int(_player.position.y)
	if _mob_visuals != null:
		_mob_visuals.sync(world, world.combat, TILE_SIZE)
	_sync_camera_position()


func _sync_camera_position() -> void:
	if world == null:
		return
	var cell: Vector2i = world.get_entity_position(&"player")
	var target := Vector2(cell.x * TILE_SIZE + TILE_SIZE / 2, cell.y * TILE_SIZE + TILE_SIZE / 2)
	_camera.position = _clamp_camera_center(target)


func _clamp_camera_center(target: Vector2) -> Vector2:
	var vp := get_viewport().get_visible_rect().size
	var half := vp * 0.5
	var map_px := Vector2(_WorldZoneMap.MAP_SIZE) * float(TILE_SIZE)
	var min_x := half.x if map_px.x > vp.x else map_px.x * 0.5
	var max_x := map_px.x - half.x if map_px.x > vp.x else map_px.x * 0.5
	var min_y := half.y if map_px.y > vp.y else map_px.y * 0.5
	var max_y := map_px.y - half.y if map_px.y > vp.y else map_px.y * 0.5
	return Vector2(clampf(target.x, min_x, max_x), clampf(target.y, min_y, max_y))


func _refresh_hud() -> void:
	_hud_layer.visible = true
	var cell: Vector2i = world.get_entity_position(&"player")
	var zone_id: int = _zone_map.get_zone(cell)
	var practice := "sí" if _zone_map.is_practice_area(cell) else "no"
	var data_line := _mvp_data_hud_line()
	var lua_line := "Lua: off"
	if _editor_ctrl.is_manual_override():
		lua_line = "Lua: manual"
	elif _editor_ctrl.is_script_running():
		lua_line = "Lua: ON"
	var combat_line := _combat_hud_line()
	_hud.text = (
		"Tick %d | (%d,%d) | %s | %s\n%s | %s | %s\nWASD | E editor | Esc cerrar"
		% [world.tick_index, cell.x, cell.y, _WorldZone.id_to_string(zone_id), practice, data_line, lua_line, combat_line]
	)


func _combat_hud_line() -> String:
	if world.combat == null:
		return "Combate: off (link_mvp_data.ps1)"
	var hp: int = world.combat.get_hp(&"player")
	var xp: int = world.combat.get_player_xp()
	var gold: int = world.combat.get_player_gold()
	var alive := 0
	for id: StringName in world.combat.list_mob_entity_ids():
		if world.combat.is_entity_alive(id):
			alive += 1
	return "HP %d | XP %d | Oro %d | Mobs %d" % [hp, xp, gold, alive]


func _mvp_data_hud_line() -> String:
	if not MvpData.is_loaded():
		return "MVP data: no cargado (link_mvp_data.ps1)"
	var s = MvpData.store
	return "MVP data: %d mobs, %d items, %d quests" % [s.monsters.size(), s.items.size(), s.quests.size()]


func _on_lua_editor_closed() -> void:
	_manual_input.clear_active(world, &"player")
	_refresh_hud()


func _process(_delta: float) -> void:
	## E solo abre el editor; cerrar con Esc o botón Cerrar (evita cerrar al escribir "e").
	if Input.is_action_just_pressed("toggle_lua_editor") and not _lua_editor.is_open():
		_lua_editor.open_editor()
		_manual_input.clear_active(world, &"player")
		_refresh_hud()
	elif OS.is_debug_build() and Input.is_action_just_pressed("debug_mvp_reload"):
		if MvpData.reload():
			_lua_editor.populate_quests()
			_refresh_hud()


func _unhandled_key_input(event: InputEvent) -> void:
	if _lua_editor.is_open() and not _editor_ctrl.is_manual_override():
		return
	if _editor_ctrl.is_script_running() and event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo and _manual_input.handle_key_event(world, &"player", event):
			_editor_ctrl.interrupt_script_for_manual()
			get_viewport().set_input_as_handled()
			return
	if _manual_input.handle_key_event(world, &"player", event):
		get_viewport().set_input_as_handled()


func _on_joystick_cardinal(dir: Vector2i) -> void:
	if _lua_editor.is_open():
		return
	_manual_input.set_joystick_cardinal(world, &"player", dir)


func _load_player_texture() -> Texture2D:
	var mixel := _MixelSpriteLoader.player_idle_front()
	if mixel != null:
		return mixel
	var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.9, 0.85, 0.2))
	return ImageTexture.create_from_image(img)
