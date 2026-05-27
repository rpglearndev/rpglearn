# US-020 — Brief

## Historia

*Como* jugador,
*quiero* atacar enemigos respetando cooldown y rango (sin LoS),
*para* farmear y completar misiones de combate.

## Criterios de aceptación

1. `attack` valida rango; mago/arquero usan `setDesiredRange`.
2. Daño usa fórmula parametrizada (JSON).
3. Enemigo puede morir; XP/oro según `monsters.json`.

## Dependencias

- US-010 ✅
- US-030 / `monsters.json` ✅

## Fuera de alcance

- Spawns visuales en mapa (US-021)
- Loot/inventario (US-022)
- Tienda (US-023)
