# US-030 — Refactor

## Estado

**Completado** (sin cambio de comportamiento observable)

## Cambios

- Preloads explícitos (`LuaApiBridge`, `LuaGameRng`) para evitar errores de parse GDScript.
- `LuaError` → comprobación runtime `_is_lua_error()` (compatible headless).
- `LuaApiBridge.was_last_move_to_ok()` en lugar de acceso a campo privado en tests.
- `setup_lua_gdextension.ps1`: resuelve `addons/lua-gdextension` del zip correctamente.
- `run_tests.gd`: fallo claro si suite no instancia.

## Suite

Ver `04-e2e.md` — PASS.
