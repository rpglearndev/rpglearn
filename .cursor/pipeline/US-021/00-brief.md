# US-021 — Brief

## Historia

*Como* jugador,
*quiero* slime, lobo y bandido con dificultad creciente,
*para* progresión de combate y tutorial.

## Criterios de aceptación

1. `mob_slime`, `mob_wolf`, `mob_bandit` en `data/mvp/monsters.json` + spawns.
2. Relación de poder: slime < wolf < bandit.
3. Drops básicos (oro, chatarra vendible).

## Dependencias

- US-012 ✅
- US-020 (combate/spawns runtime) ✅

## Alcance US-021

- Sprites distinguibles por tipo (no círculos genéricos).
- Tests de datos: spawns, poder, drops referencian ítems válidos.

## Fuera de alcance

- Recoger loot en suelo (US-022)
- IA de mobs
