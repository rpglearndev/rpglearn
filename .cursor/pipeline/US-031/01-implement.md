# US-031 — Implement (TDD)

## Estado

**Completado**

## Criterios → tests

| # | Criterio | Test(s) |
|---|----------|---------|
| 1 | CodeEdit + Run/Stop | `LuaCodeEditorPanel` + `test_lua_editor_controller.gd` |
| 2 | Consola i18n keys | `test_lua_error_i18n.gd`, `log_console([key])` |
| 3 | Plantillas por quest_id | `quest_templates.json`, `test_quest_templates.gd` |
| 4 | Override manual | `LuaEditorController.enable_manual_override()` + test |

## Archivos

- `data/mvp/quest_templates.json`
- `scripts/ui/lua_code_editor_panel.gd`, `lua_editor_controller.gd`
- `scripts/lua/lua_error_i18n.gd`
- `MvpDataLoader` / `MvpDataStore` — templates
- `world_01` + tecla **E** (`toggle_lua_editor`)
