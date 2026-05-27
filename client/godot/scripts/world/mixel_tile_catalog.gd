class_name MixelTileCatalog
extends RefCounted
## Atlas Mixel: terreno vía Godot Terrain; ruinas, rocas y detalles manuales.

const ASSETS_ROOT := "res://assets/mixel/"

const GROUND_ATLAS := (
	ASSETS_ROOT + "Nature v1.5/Topdown RPG 32x32 - Ground Tileset 1.2.PNG"
)
const ROCKS_ATLAS := ASSETS_ROOT + "Nature v1.5/Topdown RPG 32x32 - Rocks 1.2.PNG"
const RUINS_ATLAS := ASSETS_ROOT + "Buildings v.1.1/Topdown RPG 32x32 - Ruins.PNG"
const DETAILS_ATLAS := ASSETS_ROOT + "Nature v1.5/Topdown RPG 32x32 - Nature Details.png"
const TREES_ATLAS := ASSETS_ROOT + "Nature v1.5/Topdown RPG 32x32 - Trees 1.2.PNG"

const SOURCE_GROUND := 0
const SOURCE_ROCKS := 1
const SOURCE_RUINS := 2
const SOURCE_DETAILS := 3
const SOURCE_TREES := 4

const TILE_SIZE := 32

const _DETAIL_VARIANTS: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(4, 2), Vector2i(5, 2),
]

const _TREE_VARIANTS: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
]


## Ruinas / rocas (terreno grass+dirt usa autotile en map builder).
static func tile_for_kind(kind: int) -> Dictionary:
	const World01Layout := preload("res://scripts/world/world_01_layout.gd")
	match kind:
		World01Layout.TileKind.FENCE:
			return {"source": SOURCE_ROCKS, "atlas": Vector2i(4, 0)}
		World01Layout.TileKind.BUILDING:
			return {"source": SOURCE_RUINS, "atlas": Vector2i(2, 2)}
		_:
			return {"source": SOURCE_GROUND, "atlas": Vector2i(11, 0)}


static func decoration_for_cell(cell: Vector2i) -> Dictionary:
	# Árboles grandes cada ~8 celdas; resto hierba/flores del sheet Details.
	if cell.x % 8 == 3 and cell.y % 6 == 2:
		var tidx := (cell.x + cell.y) % _TREE_VARIANTS.size()
		return {"source": SOURCE_TREES, "atlas": _TREE_VARIANTS[tidx]}
	var idx := (cell.x * 3 + cell.y) % _DETAIL_VARIANTS.size()
	return {"source": SOURCE_DETAILS, "atlas": _DETAIL_VARIANTS[idx]}


static func atlas_paths() -> PackedStringArray:
	return PackedStringArray([GROUND_ATLAS, ROCKS_ATLAS, RUINS_ATLAS, DETAILS_ATLAS, TREES_ATLAS])
