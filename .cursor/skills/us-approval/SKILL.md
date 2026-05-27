---
name: us-approval
description: >-
  Gate de aprobación humana del pipeline US rpglearn. Presenta resumen ejecutivo
  al usuario y espera visto bueno explícito antes de cerrar issue o marcar Done.
  Usar tras E2E PASS o cuando el usuario diga Aprobado/Rechaza US-XXX.
---

# Gate — Aprobación humana (Product Owner)

## Identidad

El orquestador actúa como **facilitador**; **tú (el usuario)** eres el decisor final. Ningún agente cierra la US sin tu palabra.

## Cuándo activar

- Tras `04-e2e.md` con **PASS** **y** sección “Evidencia de ejecución” con exit code `0` y salida pegada.
- Si `04-e2e.md` es PASS sin salida de comando → tratar como **FAIL de proceso**; re-ejecutar E2E, no pedir aprobación.
- Con **FAIL** o **BLOCKED** → no pedir aprobación; volver atrás.
- Usuario escribe: `Aprobado US-XXX`, `Visto bueno US-XXX`, `Rechaza US-XXX`.

## Mensaje al usuario (plantilla obligatoria)

```markdown
## US-XXX — Lista para tu revisión

### Entregado
- [bullets de funcionalidad]

### Evidencia
- Implement: `.cursor/pipeline/US-XXX/01-implement.md`
- Review: `02-review.md` — veredicto: …
- Refactor: `03-refactor.md`
- E2E: `04-e2e.md` — …

### Criterios de aceptación
| # | ✅/❌ |
|---|------|

### Cómo probar en tu máquina
1. …

---

**Responde una de:**
- `Aprobado US-XXX` — commit, push, merge a `master` y luego cierro issue / Done
- `Rechaza US-XXX` — indica fase (implement/review/e2e) y motivo
```

## Si `Aprobado US-XXX`

Orden **obligatorio** (no invertir pasos 2–4 y 5):

1. Escribir `05-approval.md` con fecha, frase del usuario, resumen.
2. **Git — integrar código** (ejecutar tú, no pedir al usuario):
   - `git status` / `git diff` — revisar cambios pendientes.
   - `git add` + `git commit` en la rama `us/XXX-…` si hay cambios sin commitear.
   - `git push -u origin HEAD` (rama de la US).
   - `git checkout master` → `git pull origin master`.
   - `git merge us/XXX-…` (fast-forward o merge commit según historial).
   - `git push origin master`.
3. **Board — solo después del push a master:**
   - `scripts/us_pipeline.ps1 approve US-XXX`.
4. Confirmar issue cerrada y card en **Done**; indicar commit/merge en el mensaje al usuario.

## Si `Rechaza US-XXX`

1. Registrar motivo en `05-approval.md` (estado: rechazado).
2. Mover board a **In Progress** o fase indicada (`scripts/us_pipeline.ps1 start US-XXX`).
3. Re-lanzar solo la fase pedida (no repetir pipeline entero salvo que el usuario lo pida).

## Prohibido

- Asumir aprobación por silencio o por "parece bien".
- Ejecutar `approve US-XXX` (cerrar issue / Done) **antes** de commit + push + merge a `master`.
- Cerrar issue sin que el código de la US esté en `origin/master`.
