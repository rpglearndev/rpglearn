# US-030 — Brief

## Historia

*Como* jugador que aprende a programar,
*quiero* ejecutar scripts Lua con API limitada del juego,
*para* automatizar acciones sin riesgos de seguridad.

## Criterios de aceptación

1. Script corre en sandbox; errores capturados con línea.
2. API MVP expuesta según desbloqueos de misión.
3. `moveTo` usa A* completo; falla controlado sin path.
4. RNG solo vía API del motor con seed fija en modo reto.

## Dependencias

- US-010 ✅ (TickWorld, GameAction)
- US-090 ✅ (quests `api_unlock` en JSON)

## Alcance técnico

- `GridPathfinder` (A* sobre `GridWalkability`)
- `LuaSandbox` + `LuaApiBridge` (whitelist, sin os/io/red)
- Watchdog instrucciones por tick
- `game.random()` con seed fija en modo reto
- Integración mínima en `world_01` (tecla Run script debug)

## Fuera de alcance

- Editor UI completo (US-031)
- Combate/loot API completa (US-020+)
