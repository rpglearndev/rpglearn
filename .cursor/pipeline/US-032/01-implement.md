# US-032 — Implement

## Criterios → tests

| # | Test |
|---|------|
| 1 | `test_quest_script_validator.gd` (misiones 2–5) |
| 2 | Mensajes missing/hint/example en `QuestValidationI18n` |
| 3 | `test_lua_script_timeout.gd` + `MAX_SCRIPT_TICKS` / `MAX_ACTIONS_PER_LUA_TICK` |

## Archivos

- `scripts/quest/quest_script_validator.gd`
- `scripts/quest/quest_validation_i18n.gd`
- Editor: botón **Validar**, Run exige validación si hay quest seleccionada
- `lua_script_runner` / `lua_api_bridge` — límites runtime
