# RPG Learn

RPG 2D single-player donde aprendes a programar en **Lua** para automatizar tu personaje. Godot 4 (cliente) + Node.js (backend/rankings).

## Documentación

- [Plan de diseño](docs/plan.md)
- [Backlog / User Stories](docs/backlog.md)
- [Workflow pipeline por US (TDD → review → refactor → E2E → tu OK)](docs/workflow-us-pipeline.md)

## Estructura

```
client/godot/   # Godot 4 — juego
server/         # Node.js TypeScript — API + sim-worker (Fase 2)
data/mvp/       # JSON: monsters, items, quests, shop, spawns
assets/         # Arte (Mixel, DB32) + CREDITS.md
docs/           # plan.md, backlog.md
```

## Cliente (Godot)

1. Instala [Godot 4.3+](https://godotengine.org/).
2. Importa `client/godot/` en el editor.
3. Tests del tick engine: `.\scripts\run_godot_tests.ps1` (o define `GODOT_PATH`).
4. Escena debug: `scenes/debug/tick_debug.tscn`.

## Servidor (futuro)

```bash
cd server
npm install
npm run dev
```

## Desarrollo por User Story

Orden en Cursor:

```
Implementa US-010
```

Pipeline: **Implement (TDD)** → **Review** → **Refactor** → **E2E** → tu **`Aprobado US-010`**.

Agentes y reglas en `.cursor/AGENTS.md` y `.cursor/skills/`.

## Organización GitHub

- Org: [rpglearndev](https://github.com/rpglearndev)
- Issues: prefijo `US-###`
- Project: **MVP Roadmap**

## Licencia

Código del repo: ver `LICENSE`. Assets de terceros: ver `CREDITS.md`.
