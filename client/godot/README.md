# RPG Learn — Cliente Godot 4

## Requisitos

- [Godot 4.3+](https://godotengine.org/) (probado con 4.6.3)

## Abrir proyecto

Importa esta carpeta (`client/godot`) en el editor Godot.

## Tests (US-010)

Desde la raíz del repo, con `godot` en el PATH:

Desde la raíz del repo:

```powershell
.\scripts\run_godot_tests.ps1
```

Detecta automáticamente `C:\Program Files\Godot\Godot*.exe` o usa `GODOT_PATH`.

## Escena debug

`scenes/debug/tick_debug.tscn` — muestra tick index y encola movimientos con WASD.

## Core

- `scripts/core/tick_world.gd` — simulación por ticks (10 TPS por defecto)
- `scripts/core/tick_world_runner.gd` — dispara ticks desde tiempo real sin usar delta en reglas
