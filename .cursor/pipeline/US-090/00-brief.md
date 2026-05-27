# US-090 — Brief

## Historia

*Como* desarrollador,
*quiero* monsters, items, quests, shop y spawns en JSON,
*para* balancear sin recompilar.

## Criterios de aceptación

1. Archivos en `data/mvp/` cargados al inicio.
2. Hot-reload en editor debug (opcional).
3. Coherente con tablas del plan.

## Dependencias

- US-001 ✅

## Alcance

- JSON: `monsters`, `items`, `quests`, `shop`, `spawns` en `data/mvp/`.
- Autoload Godot `MvpData` carga al arranque; tests unitarios del loader.
- Hot-reload con tecla debug (F9) en builds debug.

## Fuera de alcance

- Combate, spawns en runtime, UI tienda (US-020+).
