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
const _LuaSandbox := preload("res://scripts/lua/lua_sandbox.gd")

const TILE_SIZE := 32

@onready var _ground: TileMapLayer = $Ground
@onready var _decor: TileMapLayer = $Decor
@onready var _entities: Node2D = $Entities
@onready var _player: Sprite2D = $Entities/Player
@onready var _camera: Camera2D = $Camera2D
@onready var _hud: Label = $HUD/InfoLabel
@onready var _joystick: Control = $HUD/VirtualJoystick

var world = null
var _runner = null
var _manual_input = null
var _zone_map = null
var _lua_runner = null
var _lua_status: String = ""


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.35, 0.55, 0.28))
	_zone_map = _WorldZoneMap.new()
	var walkability := _World01MapBuilder.apply_to_layer(_ground, _decor)
	world = _TickWorld.new(walkability)
	_manual_input = _ManualTickInput.new()
	world.set_entity_position(&"player", Vector2i(8, 13))
	world.tick_processed.connect(_on_tick_processed)
	_runner = _TickWorldRunner.new()
	_runner.world = world
	add_child(_runner)
	_entities.y_sort_enabled = true
	_player.texture = _load_player_texture()
	_setup_camera_limits()
	_sync_player_visual()
	if _joystick.has_signal("cardinal_changed"):
		_joystick.cardinal_changed.connect(_on_joystick_cardinal)
	_lua_runner = _LuaScriptRunner.new()
	_lua_runner.setup(world, &"player")
	_refresh_hud()


func _on_tick_processed(_tick_index: int) -> void:
	if _lua_runner != null and _lua_runner.enabled:
		_lua_runner.on_world_tick()
		if not _lua_runner.enabled:
			_lua_status = "error: %s" % _lua_runner.get_last_lua_error()
	else:
		_manual_input.on_tick_processed(world, &"player")
	_sync_player_visual()
	_refresh_hud()


func _setup_camera_limits() -> void:
	_camera.enabled = true
	_camera.make_current()
	_sync_camera_position()


func _sync_player_visual() -> void:
	var cell: Vector2i = world.get_entity_position(&"player")
	_player.position = Vector2(cell.x * TILE_SIZE + TILE_SIZE / 2, cell.y * TILE_SIZE + TILE_SIZE / 2)
	_player.z_index = int(_player.position.y)
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
	var cell: Vector2i = world.get_entity_position(&"player")
	var zone_id: int = _zone_map.get_zone(cell)
	var practice := "sí" if _zone_map.is_practice_area(cell) else "no"
	var data_line := _mvp_data_hud_line()
	var lua_line := "Lua: off"
	if _lua_runner != null and _lua_runner.enabled:
		lua_line = "Lua: ON"
	elif not _lua_status.is_empty():
		lua_line = "Lua: %s" % _lua_status
	_hud.text = (
		"World_01 | Tick %d | Player (%d,%d) | Zona: %s | Práctica: %s\n%s | %s\nWASD + joystick | L = Lua demo (también 0 / F10)"
		% [world.tick_index, cell.x, cell.y, _WorldZone.id_to_string(zone_id), practice, data_line, lua_line]
	)


func _mvp_data_hud_line() -> String:
	if not MvpData.is_loaded():
		return "MVP data: no cargado (link_mvp_data.ps1)"
	var s = MvpData.store
	return "MVP data: %d mobs, %d items, %d quests" % [s.monsters.size(), s.items.size(), s.quests.size()]


func _process(_delta: float) -> void:
	## InputMap: L / 0 / F10 (portátiles sin fila F suelen mandar 0 con Fn, no F10).
	if Input.is_action_just_pressed("debug_lua_demo"):
		_toggle_lua_demo()
	elif OS.is_debug_build() and Input.is_action_just_pressed("debug_mvp_reload"):
		if MvpData.reload():
			_refresh_hud()


func _unhandled_key_input(event: InputEvent) -> void:
	if _manual_input.handle_key_event(world, &"player", event):
		get_viewport().set_input_as_handled()


func _on_joystick_cardinal(dir: Vector2i) -> void:
	_manual_input.set_joystick_cardinal(world, &"player", dir)


func _toggle_lua_demo() -> void:
	if not _LuaSandbox.is_extension_available():
		_lua_status = "extensión no instalada — ejecuta scripts/setup_lua_gdextension.ps1 y reabre el proyecto"
		push_warning(_lua_status)
		_refresh_hud()
		return
	if _lua_runner.enabled:
		_lua_runner.enabled = false
		_lua_status = "off"
		_refresh_hud()
		return
	var src := """
function on_tick()
  local pos = getPosition()
  if pos.x < 14 then
    move("E")
  elseif pos.x > 16 then
    move("W")
  end
end
"""
	if _lua_runner.load_source(src):
		_lua_runner.enabled = true
		_manual_input.clear_active(world, &"player")
		_lua_status = ""
	else:
		_lua_status = "error carga: %s" % _lua_runner.get_last_lua_error()
		push_warning("Lua demo: %s" % _lua_status)
	_refresh_hud()


func _load_player_texture() -> Texture2D:
	var mixel := _MixelSpriteLoader.player_idle_front()
	if mixel != null:
		return mixel
	var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.9, 0.85, 0.2))
	return ImageTexture.create_from_image(img)
