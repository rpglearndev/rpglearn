class_name World01TilesetFactory
extends RefCounted
## TileSet 32×32 Mixel: terreno autotile + ruinas, rocas, árboles, detalles.

const MixelTileCatalog := preload("res://scripts/world/mixel_tile_catalog.gd")
const MixelGroundTerrainSetup := preload("res://scripts/world/mixel_ground_terrain_setup.gd")
const MixelSpriteLoader := preload("res://scripts/world/mixel_sprite_loader.gd")
const World01Layout := preload("res://scripts/world/world_01_layout.gd")

const TILE_SIZE := 32


static func create_tile_set() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	var paths := MixelTileCatalog.atlas_paths()
	var source_ids: Array[int] = [
		MixelTileCatalog.SOURCE_GROUND,
		MixelTileCatalog.SOURCE_ROCKS,
		MixelTileCatalog.SOURCE_RUINS,
		MixelTileCatalog.SOURCE_DETAILS,
		MixelTileCatalog.SOURCE_TREES,
	]
	for i in paths.size():
		var source := _add_atlas_source(tile_set, source_ids[i], paths[i])
		if source_ids[i] == MixelTileCatalog.SOURCE_GROUND:
			MixelGroundTerrainSetup.configure(tile_set, source)

	_register_manual_tiles(tile_set)
	return tile_set


static func _add_atlas_source(tile_set: TileSet, source_id: int, texture_path: String) -> TileSetAtlasSource:
	var texture: Texture2D = MixelSpriteLoader.load_texture(texture_path)
	var source := TileSetAtlasSource.new()
	if texture == null:
		push_error("World01TilesetFactory: missing texture %s" % texture_path)
		tile_set.add_source(source, source_id)
		return source
	source.texture = texture
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var cols := texture.get_width() / TILE_SIZE
	var rows := texture.get_height() / TILE_SIZE
	for y in rows:
		for x in cols:
			source.create_tile(Vector2i(x, y))
	tile_set.add_source(source, source_id)
	return source


static func _register_manual_tiles(tile_set: TileSet) -> void:
	var kinds: Array[int] = [
		World01Layout.TileKind.FENCE,
		World01Layout.TileKind.BUILDING,
	]
	for kind in kinds:
		var mapping: Dictionary = MixelTileCatalog.tile_for_kind(kind)
		var source: TileSetAtlasSource = tile_set.get_source(mapping.source) as TileSetAtlasSource
		if source == null:
			continue
		if not source.has_tile(mapping.atlas):
			push_error("World01TilesetFactory: missing atlas %s source %d" % [mapping.atlas, mapping.source])


static func project_uses_nearest_texture_filter() -> bool:
	return int(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter")) == 0


static func mixel_textures_available() -> bool:
	for path in MixelTileCatalog.atlas_paths():
		if not FileAccess.file_exists(ProjectSettings.globalize_path(path)):
			return false
	return true
