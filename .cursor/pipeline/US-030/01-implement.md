# US-030 — Implement (TDD)

## Estado

**Completado**

## Tests añadidos (rojo → verde)

| Suite | Cubre |
|-------|--------|
| `test_grid_pathfinder.gd` | A* rodea muro; meta bloqueada → path vacío |
| `test_lua_game_rng.gd` | Misma seed → misma secuencia |
| `test_lua_api_registry.gd` | `api_unlock` de quests + base |
| `test_lua_sandbox.gd` | Error sintaxis; `moveTo` sin path (requiere extensión) |

## Código entregado

- `scripts/core/grid_pathfinder.gd` — A* 4-dir
- `scripts/lua/lua_*.gd` — sandbox, bridge, registry, RNG, runner
- `tick_world.gd` — `get_walkability()`
- `world_01.gd` — F10 demo Lua, HUD estado
- `scripts/setup_lua_gdextension.ps1` — instala release 0.8.1
- `run_godot_tests.ps1` — import GDExtension antes de tests si addon presente

## Notas

- Extensión **no** versionada (~58 MB); `.gitignore` + setup script.
- Watchdog de instrucciones: constante definida; hook real pendiente (ver Review Minor).
