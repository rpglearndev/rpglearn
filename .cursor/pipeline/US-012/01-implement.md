# US-012 — Implement

## Criterios → tests

| # | Criterio | Test(s) / evidencia |
|---|----------|---------------------|
| 1 | TileMap 32×32 Mixel + Nearest | `World01TilesetFactory`, `project_uses_nearest_texture_filter`, escena `world_01` |
| 2 | Zonas lógicas | `WorldZoneMap`, HUD muestra zona |
| 3 | Área de práctica | `PRACTICE_INTERIOR`, vallas `FENCE` en layout |
| 4 | Y-sort entidades | `Entities.y_sort_enabled`, `Player.z_index` por Y |

## Archivos

| Archivo | Propósito |
|---------|-----------|
| `scripts/world/world_zone_map.gd` | Greenfield / Riverton / Outskirts |
| `scripts/world/world_01_layout.gd` | Grid de tiles + vallas práctica |
| `scripts/world/world_01_tileset_factory.gd` | Atlas placeholder 32×32 |
| `scripts/world/world_01_map_builder.gd` | Pinta TileMapLayer + walkability |
| `scenes/world/world_01.tscn` | Mapa jugable + input US-011 |
| `assets/mixel/README.md` | Instrucciones import pack real |

## Comandos

`.\scripts\run_godot_tests.ps1` — exit 0

## Deuda

- Sustituir placeholder por tiles Mixel reales en `assets/mixel/`.
