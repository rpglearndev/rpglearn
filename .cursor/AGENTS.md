# Agentes — Pipeline por User Story (rpglearn)

Cuando el usuario ordena **implementar / codificar una US** (ej. `Implementa US-010`), el agente principal actúa como **orquestador** y ejecuta las fases en orden **sin saltarse gates**.

## Comando del usuario

Frases que disparan el pipeline completo:

- `Implementa US-010`
- `Codifica US-010`
- `Empieza la US-010`

Frases de control:

- `Aprobado US-010` / `Visto bueno US-010` → cierra fase de aprobación humana y mueve board a Done
- `Rechaza US-010` → vuelve a la fase indicada (implement / review / e2e)

## Pipeline (orden estricto)

```
US-XXX solicitada
    → 1. Implementer   (TDD + código)
    → 2. Reviewer      (bloqueante si Critical)
    → 3. Refactorer    (sin cambiar comportamiento)
    → 4. E2E Tester    (criterios de aceptación)
    → 5. Humano        (visto bueno explícito)
    → Done en GitHub Project + issue cerrada
```

## Agentes y skills

| Fase | Skill | Rol |
|------|-------|-----|
| Orquestación | `.cursor/skills/us-pipeline/SKILL.md` | Coordina fases, artefactos, board |
| 1 | `.cursor/skills/us-implement/SKILL.md` | TDD, implementación mínima |
| 2 | `.cursor/skills/us-review/SKILL.md` | Code review vs plan y US |
| 3 | `.cursor/skills/us-refactor/SKILL.md` | Clean Code sin cambiar API pública |
| 4 | `.cursor/skills/us-e2e/SKILL.md` | Pruebas E2E / aceptación |
| 5 | `.cursor/skills/us-approval/SKILL.md` | Gate humano; no avanzar sin OK |

## Artefactos por US

Carpeta: `.cursor/pipeline/US-XXX/`

- `00-brief.md` — criterios de aceptación copiados de `docs/backlog.md`
- `01-implement.md` — resumen TDD + archivos tocados
- `02-review.md` — hallazgos (Critical / Suggestion / Nice)
- `03-refactor.md` — cambios de refactor
- `04-e2e.md` — evidencia de pruebas
- `05-approval.md` — registro del visto bueno del usuario

## Reglas globales

- `.cursor/rules/rpglearn-architecture.mdc` — arquitectura Godot/Node, ticks, determinismo
- `.cursor/rules/us-pipeline-gates.mdc` — no saltar fases ni cerrar sin aprobación

## Referencias

- Plan: `docs/plan.md`
- Backlog: `docs/backlog.md`
- Board: https://github.com/orgs/rpglearndev/projects/1
