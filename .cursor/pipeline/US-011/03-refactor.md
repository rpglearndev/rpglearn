# US-011 — Refactor

## Cambios

| Archivo | Cambio |
|---------|--------|
| `tests/unit/test_manual_tick_input.gd` | `_simulate_tick` sin `connect()` para evitar leaks en runner headless |
| `tick_world.gd` | API mínima `clear_action_queue` |

Comportamiento observable: igual que diseño acordado.
