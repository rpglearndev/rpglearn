class_name WorldZoneMap
extends RefCounted
## Zonas lógicas de world_01 por coordenada de celda (metadata; no depende del TileMap).

const WorldZone := preload("res://scripts/world/world_zone.gd")

## Rectángulo interior del área de práctica (sin el borde de valla).
const PRACTICE_INTERIOR := Rect2i(5, 5, 7, 7)

## Salida sur del recinto (celda walkable; el resto del perímetro bloquea).
const PRACTICE_GATE := Vector2i(8, 12)

## Límites del mapa en tiles.
const MAP_SIZE := Vector2i(48, 28)


func get_zone(cell: Vector2i) -> int:
	if cell.x < 0 or cell.y < 0 or cell.x >= MAP_SIZE.x or cell.y >= MAP_SIZE.y:
		return WorldZone.Id.OUTSKIRTS
	if cell.x >= 34:
		return WorldZone.Id.OUTSKIRTS
	if cell.x >= 19 and cell.x <= 33 and cell.y >= 4 and cell.y <= 22:
		return WorldZone.Id.RIVERTON
	return WorldZone.Id.GREENFIELD


func is_practice_area(cell: Vector2i) -> bool:
	return PRACTICE_INTERIOR.has_point(cell)


func practice_bounds() -> Rect2i:
	return PRACTICE_INTERIOR
