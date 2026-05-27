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

Salida esperada: `All tests passed (TickWorld + ManualTickInput).`

## Escena debug

`scenes/debug/tick_debug.tscn` — ticks + **WASD** + **joystick** (abajo-izquierda, ratón o touch).

## Joystick (US-011)

- Nodo **VirtualJoystick** en la escena debug; script `scripts/input/virtual_joystick_control.gd`.
- Ratón: clic y arrastra en el círculo; suelta para parar (vacía la cola como soltar tecla).
- Dirección llega a `ManualTickInput.set_joystick_cardinal()` (prioridad sobre cola tipo bot).

## Core / input

- `scripts/core/tick_world.gd` — simulación por ticks (10 TPS por defecto)
- `scripts/core/tick_world_runner.gd` — dispara ticks desde tiempo real (sin delta en reglas)
- `scripts/input/manual_tick_input.gd` — teclado + joystick vía `joystick_cardinal` / `set_joystick_cardinal`
