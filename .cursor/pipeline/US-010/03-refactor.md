# US-010 — Refactor

## Cambios (comportamiento igual)

| Archivo | Cambio |
|---------|--------|
| `tick_world.gd` | Constante `DEFAULT_TICKS_PER_SECOND`; getter `tick_duration_seconds` |
| `game_action.gd` | Factory `GameAction.move()` y `is_major_type()` |

## Tests

- Comando: `.\scripts\run_godot_tests.ps1`
- Resultado: pendiente ejecución local (Godot no en PATH del agente)
