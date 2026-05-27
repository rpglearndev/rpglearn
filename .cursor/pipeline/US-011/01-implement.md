# US-011 — Implement

## Criterios → tests

| # | Criterio | Test(s) |
|---|----------|---------|
| 1 | WASD 1 tile; mantener = 1/tick | `test_key_press_clears_bot_queue_and_moves`, `test_hold_one_tile_per_tick` |
| 2 | Joystick (UI + cardinal) | `test_joystick_*`, `test_joystick_clears_bot_queue` |
| 3 | Manual anula cola (bot/script) | `test_key_press_clears_bot_queue_and_moves` + `TickWorld.clear_action_queue` |
| — | Cola vaciable | `test_clear_action_queue` |

## Archivos

| Archivo | Propósito |
|---------|-----------|
| `scripts/input/manual_tick_input.gd` | WASD/hold/stub joystick + prioridad manual |
| `scripts/core/tick_world.gd` | `clear_action_queue()` |
| `tests/unit/test_manual_tick_input.gd` | Suite US-011 |
| `tests/run_tests.gd` | Ejecuta TickWorld + ManualTickInput |
| `scenes/debug/tick_debug.gd` | Integración WASD + joystick |

## Comandos
.\scripts\run_godot_tests.ps1
```

Resultado: exit 0.
