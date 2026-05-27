# US-032 — Brief

## Historia

*Como* jugador principiante,
*quiero* feedback si mi script usa variables, if, loops o funciones correctamente,
*para* aprender como en un curso real.

## Criterios de aceptación

1. Checks por misión según sección "Plantillas y validación didáctica".
2. Mensajes: qué faltó, ejemplo mínimo, pista.
3. Detectar loop infinito / timeout.

## Dependencias

- US-031 ✅
- `quests.json` + `quest_templates.json`

## Alcance (misiones 2–5)

| quest_id | Checks |
|----------|--------|
| quest_variables_state | local hp/mana, getPosition, uso de pos |
| quest_if_safe_or_heal | if + else |
| quest_loop_patrol | for/while acotado, no while true |
| quest_function_move_to_flag | function + llamada propia |

## Fuera de alcance

- Simulación HP bajo/alto (US-052)
- Validación misiones 6–10
