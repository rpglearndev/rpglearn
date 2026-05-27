# MVP data pack (US-090)

JSON de balance y contenido. Fuente de verdad para combate, loot, tienda y misiones (ver `docs/plan.md`).

- `combat.json` — rangos, cooldown, fórmula de daño, defaults del jugador.

| Archivo | Contenido |
|---------|-----------|
| `combat.json` | rango, cooldown, fórmula de daño |
| `monsters.json` | `mob_slime`, `mob_wolf`, `mob_bandit` |
| `items.json` | armas, armadura, pociones, loot vendible |
| `quests.json` | 10 misiones tutorial + `api_unlock` |
| `shop.json` | Riverton trader (buy/sell) |
| `spawns.json` | spawns `world_01` por zona |

Godot: `res://data/mvp/` vía junction (`scripts/link_mvp_data.ps1`). Autoload `MvpData`.
