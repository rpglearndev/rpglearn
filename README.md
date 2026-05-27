# RPG Learn

RPG 2D single-player donde aprendes a programar en **Lua** para automatizar tu personaje. Godot 4 (cliente) + Node.js (backend/rankings).

## Documentación

- [Plan de diseño](docs/plan.md)
- [Backlog / User Stories](docs/backlog.md)

## Estructura

```
client/godot/   # Godot 4 — juego
server/         # Node.js TypeScript — API + sim-worker (Fase 2)
data/mvp/       # JSON: monsters, items, quests, shop, spawns
assets/         # Arte (Mixel, DB32) + CREDITS.md
docs/           # plan.md, backlog.md
```

## Cliente (Godot)

1. Instala [Godot 4.x](https://godotengine.org/).
2. Importa el proyecto en `client/godot/` (cuando exista `project.godot`).

## Servidor (futuro)

```bash
cd server
npm install
npm run dev
```

## Organización GitHub

- Org: [rpglearndev](https://github.com/rpglearndev)
- Issues: prefijo `US-###`
- Project: **MVP Roadmap**

## Licencia

Código del repo: ver `LICENSE`. Assets de terceros: ver `CREDITS.md`.
