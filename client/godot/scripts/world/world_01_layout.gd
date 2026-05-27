class_name World01Layout
extends RefCounted
## Definición estática del mapa world_01 (tiles + bloqueos). Visual vía MixelTileCatalog.

const WorldZoneMap := preload("res://scripts/world/world_zone_map.gd")
const _WorldZone := preload("res://scripts/world/world_zone.gd")

enum TileKind {
	GRASS,
	PATH,
	FENCE,
	BUILDING,
	DIRT,
}

const TILE_SIZE := 32

## [y][x] — ancho MAP_SIZE.x, alto MAP_SIZE.y
static func build_tile_grid() -> Array:
	var w := WorldZoneMap.MAP_SIZE.x
	var h := WorldZoneMap.MAP_SIZE.y
	var grid: Array = []
	for y in h:
		var row: Array = []
		for x in w:
			row.append(_tile_at(x, y))
		grid.append(row)
	return grid


static func _tile_at(x: int, y: int) -> int:
	var zones := WorldZoneMap.new()
	var cell := Vector2i(x, y)
	if _is_practice_fence(x, y):
		return TileKind.FENCE
	var zone := zones.get_zone(cell)
	match zone:
		_WorldZone.Id.RIVERTON:
			if y == 13 and x >= 20 and x <= 32:
				return TileKind.PATH
			if (x - 22) * (x - 22) + (y - 12) * (y - 12) < 9:
				return TileKind.BUILDING
			return TileKind.PATH
		_WorldZone.Id.OUTSKIRTS:
			return TileKind.DIRT
		_:
			return TileKind.GRASS


static func is_fence_cell(x: int, y: int) -> bool:
	return _is_practice_fence(x, y)


static func _is_practice_fence(x: int, y: int) -> bool:
	var cell := Vector2i(x, y)
	if cell == WorldZoneMap.PRACTICE_GATE:
		return false
	var inner := WorldZoneMap.PRACTICE_INTERIOR
	var outer := Rect2i(inner.position.x - 1, inner.position.y - 1, inner.size.x + 2, inner.size.y + 2)
	return outer.has_point(cell) and not inner.has_point(cell)


static func is_walkable_tile(kind: int) -> bool:
	return kind in [TileKind.GRASS, TileKind.PATH, TileKind.DIRT]
