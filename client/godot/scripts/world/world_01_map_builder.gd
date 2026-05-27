class_name World01MapBuilder
extends RefCounted
## Pinta TileMapLayer (terreno Mixel + decoración) y devuelve walkability.

const World01Layout := preload("res://scripts/world/world_01_layout.gd")
const World01TilesetFactory := preload("res://scripts/world/world_01_tileset_factory.gd")
const MixelTileCatalog := preload("res://scripts/world/mixel_tile_catalog.gd")
const MixelGroundTerrainSetup := preload("res://scripts/world/mixel_ground_terrain_setup.gd")
const GridWalkability := preload("res://scripts/core/grid_walkability.gd")
const WorldZoneMap := preload("res://scripts/world/world_zone_map.gd")
const WorldZone := preload("res://scripts/world/world_zone.gd")


static func apply_to_layer(ground: TileMapLayer, decor: TileMapLayer = null) -> GridWalkability:
	var tile_set := World01TilesetFactory.create_tile_set()
	ground.tile_set = tile_set
	ground.clear()
	if decor != null:
		decor.tile_set = tile_set
		decor.clear()

	var grid := World01Layout.build_tile_grid()
	var walk := GridWalkability.new()
	var grass_cells: Array[Vector2i] = []
	var dirt_cells: Array[Vector2i] = []

	for y in grid.size():
		var row: Array = grid[y]
		for x in row.size():
			var kind: int = row[x]
			var cell := Vector2i(x, y)
			if not World01Layout.is_walkable_tile(kind):
				walk.set_blocked(cell)
			match kind:
				World01Layout.TileKind.GRASS:
					grass_cells.append(cell)
				World01Layout.TileKind.PATH, World01Layout.TileKind.DIRT:
					dirt_cells.append(cell)
				World01Layout.TileKind.FENCE:
					var fence: Dictionary = MixelTileCatalog.tile_for_kind(kind)
					ground.set_cell(cell, fence.source, fence.atlas)
				World01Layout.TileKind.BUILDING:
					var building: Dictionary = MixelTileCatalog.tile_for_kind(kind)
					ground.set_cell(cell, building.source, building.atlas)

	if not grass_cells.is_empty():
		ground.set_cells_terrain_connect(
			grass_cells,
			MixelGroundTerrainSetup.TERRAIN_SET,
			MixelGroundTerrainSetup.TERRAIN_GRASS,
			false
		)
	if not dirt_cells.is_empty():
		ground.set_cells_terrain_connect(
			dirt_cells,
			MixelGroundTerrainSetup.TERRAIN_SET,
			MixelGroundTerrainSetup.TERRAIN_DIRT,
			false
		)

	if decor != null:
		_place_decorations(decor, grid)

	walk.set_map_bounds(Rect2i(Vector2i.ZERO, WorldZoneMap.MAP_SIZE))
	return walk


static func _place_decorations(decor: TileMapLayer, grid: Array) -> void:
	var zones := WorldZoneMap.new()
	for y in grid.size():
		var row: Array = grid[y]
		for x in row.size():
			var cell := Vector2i(x, y)
			if zones.get_zone(cell) != WorldZone.Id.GREENFIELD:
				continue
			if zones.is_practice_area(cell) or World01Layout.is_fence_cell(x, y):
				continue
			if row[x] != World01Layout.TileKind.GRASS:
				continue
			if (x * 17 + y * 31) % 19 != 0:
				continue
			var deco: Dictionary = MixelTileCatalog.decoration_for_cell(cell)
			decor.set_cell(cell, deco.source, deco.atlas)
