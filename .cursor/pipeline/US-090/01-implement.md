# US-090 — Implement

## Criterios → tests

| # | Criterio | Test(s) / evidencia |
|---|----------|---------------------|
| 1 | JSON en `data/mvp/` cargados al inicio | `MvpData` autoload + `test_mvp_data_loader.gd` |
| 2 | Hot-reload debug | **F9** en `world_01.gd` si `OS.is_debug_build()` |
| 3 | Coherente con plan | 3 mobs, 8+ items, 10 quests, shop Riverton, spawns `world_01` |

## Archivos

| Archivo | Propósito |
|---------|-----------|
| `data/mvp/*.json` | monsters, items, quests, shop, spawns |
| `scripts/data/mvp_data_loader.gd` | Parse JSON → `MvpDataStore` |
| `scripts/autoload/mvp_data.gd` | Carga en `_ready()` |
| `scripts/link_mvp_data.ps1` | Junction `client/godot/data/mvp` |

## Comandos

`.\scripts\run_godot_tests.ps1` — exit 0

## Deuda

- Consumo en combate/spawns (US-020, US-021).
