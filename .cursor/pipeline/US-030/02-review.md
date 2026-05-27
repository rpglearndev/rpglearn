# US-030 — Code review

## Veredicto

**Aprobado** (sin Critical)

## Criterios de aceptación

| # | Estado | Notas |
|---|--------|--------|
| 1 | ✅ | `LuaSandbox` captura `LuaError` con mensaje y línea parseada |
| 2 | ✅ | `LuaApiRegistry.unlocked_for_tutorial_complete` + quests `api_unlock` |
| 3 | ✅ | `moveTo` → A*; `_last_move_to_ok` false si meta no walkable |
| 4 | ✅ | `LuaGameRng` + `game.random` / `game.random_int`; seed 42 en `challenge_mode` |

## Hallazgos

| Severidad | Hallazgo | Acción |
|-----------|----------|--------|
| Minor | `MAX_INSTRUCTIONS_PER_CALL` no aplicado aún | Documentado; US futura o hardening |
| Minor | Stubs HP/loot/combate en bridge | Esperado (US-020+) |
| Info | Primera ejecución requiere `setup_lua_gdextension.ps1` + import Godot | README + script tests |

## Arquitectura

- ✅ Sin `os`/`io`/`package`; libs `BASE|STRING|MATH|TABLE`
- ✅ Path `moveTo`: 1 tile/tick vía cola en `LuaScriptRunner`
- ✅ Manual input después de Lua en `world_01` (US-011)
