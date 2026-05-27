# RPG Learn — Cliente Godot 4

## Requisitos

- [Godot 4.3+](https://godotengine.org/)

## Abrir proyecto

Importa esta carpeta (`client/godot`) en el editor Godot.

## Tests (US-010)

Desde la raíz del repo, con `godot` en el PATH:

```bash
godot --headless --path client/godot -s res://tests/run_tests.gd
```

Windows (ejemplo):

```powershell
& "C:\Program Files\Godot\Godot_v4.3-stable_win64.exe" --headless --path client/godot -s res://tests/run_tests.gd
```

## Escena debug

`scenes/debug/tick_debug.tscn` — muestra tick index y encola movimientos con WASD.

## Core

- `scripts/core/tick_world.gd` — simulación por ticks (10 TPS por defecto)
- `scripts/core/tick_world_runner.gd` — dispara ticks desde tiempo real sin usar delta en reglas
