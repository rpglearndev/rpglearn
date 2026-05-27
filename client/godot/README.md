# RPG Learn — Cliente Godot 4

## Requisitos

- [Godot 4.3+](https://godotengine.org/) (probado con 4.6.3)

## Abrir proyecto

Importa esta carpeta (`client/godot`) en el editor Godot.

## Tests (US-010 + US-011)

Desde la raíz del repo:

```powershell
.\scripts\run_godot_tests.ps1
```

Detecta automáticamente `C:\Program Files\Godot\Godot*.exe` o usa `GODOT_PATH`.

Salida esperada: `All tests passed (TickWorld + ManualTickInput + World01 + MvpData + Lua).`

## Escenas

| Escena | Uso |
|--------|-----|
| `scenes/world/world_01.tscn` | **Main** — mapa World_01 (US-012) + movimiento |
| `scenes/debug/tick_debug.tscn` | Solo motor de ticks (US-010) |

## Lua sandbox (US-030) + editor (US-031)

Requiere [lua-gdextension](https://github.com/gilzoide/lua-gdextension) (no va en git):

```powershell
.\scripts\setup_lua_gdextension.ps1
```

En juego: **E** abre el editor (**Esc** o **Cerrar** para salir; la E del teclado no cierra mientras escribes). **Validar**/Run/Stop, consola con scroll. Plantillas en `quest_templates.json`.

Debug: **M** recarga datos MVP.

**Si Lua no arranca:** `setup_lua_gdextension.ps1` + reimportar proyecto en Godot.

## Datos MVP (US-090)

- JSON en `data/mvp/` (repo) → `res://data/mvp/` vía `scripts/link_mvp_data.ps1`.
- Autoload **MvpData** carga al arranque; **F9** recarga en debug.

## World_01 (US-012)

- TileMap 32×32 Mixel: **autotile** césped/camino (Godot Terrain), ruinas, rocas, decoración y sprite del personaje (`res://assets/mixel/` vía `scripts/link_mixel_assets.ps1`).
- Zonas: **greenfield**, **riverton**, **outskirts** (HUD).
- Área de práctica acotada (vallas) en Greenfield.
- Capa `Entities` con **y_sort**.
- **Camera2D** sigue al jugador (mapa 48×28 tiles; la ventana no muestra todo el mundo).

## Joystick (US-011)

- Nodo **VirtualJoystick** en la escena debug; script `scripts/input/virtual_joystick_control.gd`.
- Ratón: clic y arrastra en el círculo; suelta para parar (vacía la cola como soltar tecla).
- Dirección llega a `ManualTickInput.set_joystick_cardinal()` (prioridad sobre cola tipo bot).

## Core / input

- `scripts/core/tick_world.gd` — simulación por ticks (10 TPS por defecto)
- `scripts/core/tick_world_runner.gd` — dispara ticks desde tiempo real (sin delta en reglas)
- `scripts/input/manual_tick_input.gd` — teclado + joystick vía `joystick_cardinal` / `set_joystick_cardinal`
