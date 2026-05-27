---
name: us-pipeline
description: >-
  Orquesta el pipeline completo de una User Story (US-XXX): implement TDD,
  review, refactor, E2E y gate de aprobación humana. Usar cuando el usuario
  diga implementa/codifica/empieza US-XXX, o pida el flujo automatizado de
  desarrollo por historia.
---

# Orquestador — Pipeline US

## Rol

Coordinar las fases 1→4 con subagentes o sesiones dedicadas; **no escribir código de producción** salvo scripts de pipeline. Garantizar artefactos y gates.

## Al recibir `Implementa US-XXX`

### Paso 0 — Preparación

1. Leer `docs/backlog.md` sección **US-XXX** (criterios, dependencias, epic).
2. Verificar dependencias cumplidas (issues cerradas o código existente).
3. Crear `.cursor/pipeline/US-XXX/00-brief.md` con criterios de aceptación copiados literalmente.
4. Ejecutar: `scripts/us_pipeline.ps1 start US-XXX` (mueve card a In Progress).
5. Crear rama: `us/XXX-descripcion-corta` desde `master`.

### Paso 1 — Implementer

- Invocar skill **`us-implement`** (o subagent `generalPurpose` con prompt que incluya texto completo de `us-implement/SKILL.md` + `00-brief.md`).
- **Salida requerida:** `01-implement.md`, tests en verde, código mínimo.
- Si tests no pasan → no avanzar.

### Paso 2 — Reviewer

- Invocar skill **`us-review`** con diff de la rama.
- **Salida:** `02-review.md`.
- Si hay **Critical** sin resolver → volver a Paso 1 (máx. 3 ciclos; luego escalar al usuario).

### Paso 3 — Refactorer

- Invocar skill **`us-refactor`** solo si Review no tiene Critical pendientes.
- **Salida:** `03-refactor.md`; suite completa en verde.

### Paso 4 — E2E Tester

- Invocar skill **`us-e2e`**.
- **Ejecutar** en terminal (no delegar al usuario): `.\scripts\run_godot_tests.ps1` si la US toca `client/godot`.
- **Salida:** `04-e2e.md` con **exit code**, **salida pegada** y veredicto PASS solo si exit 0.
- Si el comando no se ejecutó o falló por entorno → **BLOCKED**; no pasar a aprobación humana.

### Paso 5 — Aprobación humana (STOP)

- Invocar skill **`us-approval`**: presentar resumen al usuario.
- **No** cerrar issue ni marcar Done hasta mensaje explícito: `Aprobado US-XXX`.

### Paso 6 — Tras aprobación

- `scripts/us_pipeline.ps1 approve US-XXX`
- Commit final si queda pendiente; PR opcional según pida el usuario.

## Plantilla de estado (mensaje al usuario entre fases)

```markdown
## Pipeline US-XXX — [Fase actual]

| Fase | Estado |
|------|--------|
| Implement | ✅ / 🔄 / ⏳ |
| Review | … |
| Refactor | … |
| E2E | … |
| Tu aprobación | ⏳ pendiente |

**Siguiente:** [descripción]
**Artefactos:** `.cursor/pipeline/US-XXX/`
```

## Subagentes (Cursor Task)

Al delegar, usar prompts que empiecen con:

> Eres el agente [Implementer|Reviewer|Refactorer|E2E] del proyecto rpglearn. Lee `.cursor/skills/us-<rol>/SKILL.md` y `.cursor/pipeline/US-XXX/00-brief.md`. No saltes TDD ni criterios de aceptación.

Ver [reference.md](reference.md) para IDs de Project y convenciones de rama.
