# US-031 — Brief

## Historia

*Como* jugador,
*quiero* un editor con Run/Stop, plantillas y consola,
*para* escribir y depurar scripts dentro del juego.

## Criterios de aceptación

1. `CodeEdit` o equivalente; botones Run/Stop.
2. Consola muestra salida y errores traducibles (i18n keys).
3. Plantillas por `quest_id` cargadas desde datos.
4. Override manual disponible si script falla.

## Dependencias

- US-030 ✅ (LuaSandbox, LuaScriptRunner)

## Alcance técnico

- Panel UI en World_01 (`LuaCodeEditorPanel`)
- `data/mvp/quest_templates.json` + carga en `MvpDataLoader`
- `LuaErrorI18n` (keys ES/EN mínimas)
- `LuaEditorController` (Run/Stop/override)

## Fuera de alcance

- Validador pedagógico completo (US-032)
- i18n global UI (US-060)
