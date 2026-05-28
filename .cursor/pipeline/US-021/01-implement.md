# US-021 — Implement

## Criterios → tests

| # | Criterio | Test(s) |
|---|----------|---------|
| 1 | 3 mobs + spawns | `test_mvp_monsters_spawns.gd` |
| 2 | slime < wolf < bandit | idem + `test_mvp_data_loader.gd` |
| 3 | Drops oro/chatarra | `test_drops_reference_items` |

## Archivos

- `scripts/world/mob_sprite_loader.gd` — babosa/lobo/bandido distinguibles
- `mob_visual_spawner.gd` — usa MobSpriteLoader
- `tests/unit/test_mvp_monsters_spawns.gd`

## Comandos

- `run_godot_tests.ps1` → exit 0

## Deuda

- Arte DB32 final (sustituir procedural)
- Loot al suelo (US-022)
