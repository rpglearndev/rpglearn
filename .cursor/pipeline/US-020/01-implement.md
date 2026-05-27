# US-020 — Implement

## Criterios → tests

| # | Criterio | Test(s) |
|---|----------|---------|
| 1 | `attack` valida rango; `setDesiredRange` mago/arquero | `test_combat_system.gd` (melee, ranged) |
| 2 | Daño fórmula JSON | `test_combat_damage.gd`, `data/mvp/combat.json` |
| 3 | Muerte + XP/oro `monsters.json` | `test_combat_system.gd` (_kill_grants) |

## Archivos

- `data/mvp/combat.json` — rangos, cooldown, fórmula, defaults jugador
- `scripts/combat/*` — CombatSystem, daño, RNG, bootstrap spawns
- `tick_world.gd` / `game_action.gd` — acción ATTACK
- `lua_api_bridge.gd` — `attack`, `setDesiredRange`, `getHp`, `nearestEnemy`
- `world_01.gd` — HUD HP/XP/oro, bootstrap combate

## Comandos

- `.\scripts\run_godot_tests.ps1` → exit 0

## Deuda

- Sprites/UI de mobs (US-021)
- Loot al suelo (US-022)
