class_name MixelGroundTerrainSetup
extends RefCounted
## Configura terrenos grass/dirt en el atlas Ground Mixel (12×12) para autotile Godot.

const TERRAIN_SET := 0
const TERRAIN_GRASS := 0
const TERRAIN_DIRT := 1

const _CLASSIFICATION_ROWS: Array[String] = [
	"MMMMMMMMMMMDG",
	"MMMMMMMMMMMDG",
	"GGGGGGDDMMDD",
	"GGGGGGDDMMDD",
	"DDDDDDDDDDDM",
	"DDDDDDDDDDMD",
	"DDDDDDDDDDGG",
	"DDDDDDDDDDGG",
	"DDDDDDDDMGGG",
	"DDDDDDDDGGGG",
	"DDDDDDDDDDDD",
	"DDDDDDDDDDDD",
]

const _PEERING_OFFSETS: Dictionary = {
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE: Vector2i(1, 0),
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE: Vector2i(1, 1),
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE: Vector2i(0, 1),
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE: Vector2i(-1, 1),
	TileSet.CELL_NEIGHBOR_LEFT_SIDE: Vector2i(-1, 0),
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE: Vector2i(-1, -1),
	TileSet.CELL_NEIGHBOR_TOP_SIDE: Vector2i(0, -1),
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE: Vector2i(1, -1),
	TileSet.CELL_NEIGHBOR_RIGHT_CORNER: Vector2i(1, -1),
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER: Vector2i(1, 1),
	TileSet.CELL_NEIGHBOR_BOTTOM_CORNER: Vector2i(0, 1),
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER: Vector2i(-1, 1),
	TileSet.CELL_NEIGHBOR_LEFT_CORNER: Vector2i(-1, 0),
	TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER: Vector2i(-1, -1),
	TileSet.CELL_NEIGHBOR_TOP_CORNER: Vector2i(0, -1),
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER: Vector2i(1, -1),
}


static func configure(tile_set: TileSet, source: TileSetAtlasSource) -> void:
	if tile_set.get_terrain_sets_count() == 0:
		tile_set.add_terrain_set()
	tile_set.set_terrain_set_mode(TERRAIN_SET, TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES)
	if tile_set.get_terrains_count(TERRAIN_SET) == 0:
		tile_set.add_terrain(TERRAIN_SET)
		tile_set.set_terrain_name(TERRAIN_SET, TERRAIN_GRASS, "grass")
		tile_set.add_terrain(TERRAIN_SET)
		tile_set.set_terrain_name(TERRAIN_SET, TERRAIN_DIRT, "dirt")

	var cols := 12
	var rows := _CLASSIFICATION_ROWS.size()
	for y in rows:
		var row := _CLASSIFICATION_ROWS[y]
		for x in cols:
			var atlas := Vector2i(x, y)
			if not source.has_tile(atlas):
				continue
			var kind := row[x] if x < row.length() else "R"
			match kind:
				"G":
					_set_tile_all_peering(source, atlas, TERRAIN_GRASS)
				"D":
					_set_tile_all_peering(source, atlas, TERRAIN_DIRT)
				"M":
					_set_tile_mixed_peering(source, atlas, cols, rows)
				_:
					pass


static func _class_at(cols: int, rows: int, x: int, y: int) -> String:
	if x < 0 or y < 0 or y >= rows or x >= cols:
		return "R"
	var row := _CLASSIFICATION_ROWS[y]
	if x >= row.length():
		return "R"
	return row[x]


static func _terrain_for_kind(kind: String) -> int:
	return TERRAIN_DIRT if kind == "D" else TERRAIN_GRASS


static func _set_tile_all_peering(source: TileSetAtlasSource, atlas: Vector2i, terrain: int) -> void:
	var data := source.get_tile_data(atlas, 0)
	if data == null:
		return
	data.terrain_set = TERRAIN_SET
	data.terrain = terrain
	for bit in _PEERING_OFFSETS:
		if data.is_valid_terrain_peering_bit(bit):
			data.set_terrain_peering_bit(bit, terrain)


static func _set_tile_mixed_peering(source: TileSetAtlasSource, atlas: Vector2i, cols: int, rows: int) -> void:
	var data := source.get_tile_data(atlas, 0)
	if data == null:
		return
	var center_kind := _class_at(cols, rows, atlas.x, atlas.y)
	data.terrain_set = TERRAIN_SET
	data.terrain = _terrain_for_kind(center_kind)
	for bit in _PEERING_OFFSETS:
		if not data.is_valid_terrain_peering_bit(bit):
			continue
		var offset: Vector2i = _PEERING_OFFSETS[bit]
		var neighbor_kind := _class_at(cols, rows, atlas.x + offset.x, atlas.y + offset.y)
		data.set_terrain_peering_bit(bit, _terrain_for_kind(neighbor_kind))
