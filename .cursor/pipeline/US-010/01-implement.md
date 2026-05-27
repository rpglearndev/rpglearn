# US-010 — Implement

## Criterios → tests

| # | Criterio | Test(s) |
|---|----------|---------|
| 1 | Tickrate configurable; default 10 TPS | `test_default_tickrate`, `test_configurable_tickrate` |
| 2 | Movimiento N/S/E/W 1 tick = 1 tile walkable | `test_move_consumes_one_tick_and_one_tile`, `test_blocked_tile_does_not_move` |
| 3 | Misma secuencia → mismo resultado | `test_deterministic_replay` |
| 4 | Sin delta en lógica de juego | `TickWorld.step()` sin delta; `TickWorldRunner` solo acumula tiempo real |

## Archivos

| Archivo | Propósito |
|---------|-----------|
| `client/godot/project.godot` | Proyecto Godot 4 |
| `scripts/core/tick_world.gd` | Motor de ticks + cola de acciones |
| `scripts/core/game_action.gd` | Acciones mayores |
| `scripts/core/grid_walkability.gd` | Walkability para movimiento |
| `scripts/core/tick_world_runner.gd` | Disparo de ticks desde Node |
| `scripts/autoload/game_tick.gd` | Autoload global |
| `tests/unit/test_tick_world.gd` | Suite unitaria |
| `tests/run_tests.gd` | Runner headless |
| `scenes/debug/tick_debug.tscn` | Escena debug |
| `scripts/run_godot_tests.ps1` | Script Windows para CI local |

## Comandos

```powershell
.\scripts\run_godot_tests.ps1
# Requiere Godot 4.3+ en PATH o GODOT_PATH
```

## Deuda conocida

- Godot no instalado en entorno del agente; tests no ejecutados aquí (ejecutar en máquina del desarrollador).
