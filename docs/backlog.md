## Backlog — User Stories (formato GitHub)

Cada ítem abajo es una **Issue** lista para pegar. IDs: `US-001` …

---

### Epic E00 — Repositorio, documentación y convenciones

#### US-001 — Inicializar monorepo y documentación
*Como* desarrollador del proyecto,
*quiero* un repositorio en la org `rpglearndev` con estructura de carpetas y `docs/plan.md`,
*para* tener una base versionada antes de escribir código de juego.

**Descripción:**
Crear repo `rpglearn`, README mínimo, `.gitignore` (Godot, Node, env), subir `plan.md` y `backlog.md`, definir licencia del código propio y `CREDITS.md` para assets (Mixel, DB32 CC0).

**Criterios de aceptación:**
1. Repo accesible en `github.com/rpglearndev/rpglearn` (o nombre acordado).
2. Existe `docs/plan.md` alineado con este documento.
3. README explica cómo abrir cliente Godot y (futuro) servidor.
4. `CREDITS.md` lista fuentes de assets y licencias.

**Dependencias:** ninguna.

**Notas:** org ya creada; sin repos públicos aún.

---

#### US-002 — GitHub Project y plantilla de Issue
*Como* desarrollador,
*quiero* un Project board y plantilla de Issue con secciones Como/Quiero/Para y criterios,
*para* gestionar el MVP sin perder el formato de historias.

**Criterios de aceptación:**
1. Project *MVP Roadmap* con columnas definidas.
2. Plantilla `.github/ISSUE_TEMPLATE/user_story.md` (opcional feature request).
3. Labels `epic/*`, `phase-*`, `area/*` creados.

**Dependencias:** US-001.

---

### Epic E01 — Motor de ticks y movimiento (Fase 0)

#### US-010 — Tick engine determinista (10 TPS)
*Como* jugador (y simulador futuro),
*quiero* que el mundo avance en ticks fijos de 100 ms,
*para* que combate, movimiento y scripts sean predecibles y reproducibles.

**Descripción:**
Implementar `TickWorld` en cliente: contador global, cola de acciones, 1 acción mayor por tick, coste 1 tick por tile al mover.

**Criterios de aceptación:**
1. Tickrate configurable; default 10 TPS.
2. Movimiento discreto N/S/E/W consume 1 tick y mueve 1 tile si es walkable.
3. Tests unitarios o escena debug muestran mismo resultado con misma secuencia de inputs.
4. Sin dependencia de `delta` real para lógica de juego.

**Dependencias:** US-001, proyecto Godot base.

**Notas:** base para ranking servidor.

---

#### US-011 — Input manual WASD y joystick
*Como* jugador,
*quiero* controlar al personaje con teclado o joystick además del bot Lua,
*para* aprender manualmente y retomar control si el script falla.

**Criterios de aceptación:**
1. WASD mueve 1 tile por pulsación (o por tick según diseño acordado).
2. Joystick virtual en móvil (stub o implementación mínima en desktop).
3. Modo manual anula acciones del script en el mismo tick (prioridad manual).

**Dependencias:** US-010.

---

#### US-012 — Mapa World_01 con TileMap 32×32
*Como* jugador,
*quiero* un mapa con Greenfield, Riverton y Outskirts,
*para* explorar, farmear y hacer misiones tutorial.

**Criterios de aceptación:**
1. TileMap 32×32 con assets Mixel; filtro Nearest.
2. Zonas lógicas identificadas (metadata o layers).
3. Área de práctica acotada para misiones de código.
4. Y-sort en capa de entidades.

**Dependencias:** US-001, assets Mixel importados.

---

### Epic E02 — Combate, loot y economía básica (Fase 0)

#### US-020 — Combate melee y ranged por ticks
*Como* jugador,
*quiero* atacar enemigos respetando cooldown y rango (sin LoS),
*para* farmear y completar misiones de combate.

**Criterios de aceptación:**
1. `attack` valida rango; mago/arquero usan `setDesiredRange`.
2. Daño usa fórmula parametrizada (JSON).
3. Enemigo puede morir; XP/oro según `monsters.json`.

**Dependencias:** US-010, US-030 (datos monstruos).

---

#### US-021 — Tres monstruos MVP y spawns
*Como* jugador,
*quiero* slime, lobo y bandido con dificultad creciente,
*para* progresión de combate y tutorial.

**Criterios de aceptación:**
1. `mob_slime`, `mob_wolf`, `mob_bandit` en `data/mvp/monsters.json` + spawns.
2. Relación de poder: slime < wolf < bandit.
3. Drops básicos (oro, chatarra vendible).

**Dependencias:** US-012.

---

#### US-022 — Loot, inventario y capacidad
*Como* jugador,
*quiero* recoger loot y ver peso/capacidad,
*para* gestionar farm y misiones de inventario.

**Criterios de aceptación:**
1. `loot()` en tile actual añade ítems/oro.
2. `getInventory`, `getCapacity`, `getCarryWeight` reflejan estado real.
3. No se puede recoger si excede capacidad.

**Dependencias:** US-020, ítems DB32 mapeados.

---

#### US-023 — Tienda Riverton (buy/sell)
*Como* jugador,
*quiero* vender loot y comprar pociones en el pueblo,
*para* economía loop y misión de tienda.

**Criterios de aceptación:**
1. NPC shop en Riverton; UI o interacción por tile.
2. `buy`/`sell` vía Lua y manual (misma lógica).
3. Precios en `data/mvp/shop.json`.

**Dependencias:** US-022, US-012.

---

### Epic E03 — Lua sandbox y editor (Fase 0–1)

#### US-030 — Runtime Lua embebido con sandbox
*Como* jugador que aprende a programar,
*quiero* ejecutar scripts Lua con API limitada del juego,
*para* automatizar acciones sin riesgos de seguridad.

**Descripción:**
Integrar Lua en Godot; bloquear `os`, `io`, red; whitelist de funciones; watchdog de instrucciones; 1 acción mayor/tick.

**Criterios de aceptación:**
1. Script corre en sandbox; errores capturados con línea.
2. API MVP expuesta según desbloqueos de misión.
3. `moveTo` usa A* completo; falla controlado sin path.
4. RNG solo vía API del motor con seed fija en modo reto.

**Dependencias:** US-010.

---

#### US-031 — Editor de código in-game
*Como* jugador,
*quiero* un editor con Run/Stop, plantillas y consola,
*para* escribir y depurar scripts dentro del juego.

**Criterios de aceptación:**
1. `CodeEdit` o equivalente; botones Run/Stop.
2. Consola muestra salida y errores traducibles (i18n keys).
3. Plantillas por `quest_id` cargadas desde datos.
4. Override manual disponible si script falla.

**Dependencias:** US-030.

---

#### US-032 — Validador pedagógico misiones 2–5
*Como* jugador principiante,
*quiero* feedback si mi script usa variables, if, loops o funciones correctamente,
*para* aprender como en un curso real.

**Criterios de aceptación:**
1. Checks por misión según sección "Plantillas y validación didáctica".
2. Mensajes: qué faltó, ejemplo mínimo, pista.
3. Detectar loop infinito / timeout.

**Dependencias:** US-031, misiones definidas en `quests.json`.

---

### Epic E04 — Clases, skills y equipo (Fase 1)

#### US-040 — Selección de clase y equipo inicial
*Como* jugador nuevo,
*quiero* elegir Guerrero, Mago o Arquero con equipo inicial,
*para* empezar con identidad de rol.

**Criterios de aceptación:**
1. Pantalla creación: nombre + clase.
2. Equipo inicial según tabla del plan (`wpn_*`, `arm_cloth_tunic`, etc.).
3. Stats derivados de equipo visible en UI.

**Dependencias:** US-022, `items.json`.

---

#### US-041 — Skills por uso con anti-farm (N=10)
*Como* jugador,
*quiero* que melee/ranged/magic suban al usar armas, con tope si no acierto,
*para* evitar subir skill contra enemigos imposibles.

**Criterios de aceptación:**
1. XP por intento de ataque; stop tras 10 intentos sin hit global hasta 1 hit.
2. Curva de nivel de skill parametrizada.
3. Daño escala con skill + arma + nivel.

**Dependencias:** US-020.

---

#### US-042 — Equipamiento (slots y stats atk/def)
*Como* jugador,
*quiero* equipar arma, escudo, casco, armadura y botas,
*para* progresar con loot y tienda.

**Criterios de aceptación:**
1. Slots definidos; `equip`/`unequip` manual y Lua.
2. Solo `attack`/`defense` + `levelReq` en MVP.
3. Iconos DB32 en UI (16→32 Nearest).

**Dependencias:** US-040, US-022.

---

#### US-043 — Saltar tutorial (jugador avanzado)
*Como* jugador que ya sabe programar,
*quiero* saltar el tutorial y tener API completa desbloqueada,
*para* jugar sin fricción pedagógica.

**Criterios de aceptación:**
1. Opción en menú con confirmación.
2. Marca misiones 2–10 completadas localmente; desbloquea API MVP.
3. No afecta rankings Standard (build fijo).

**Dependencias:** US-032, sistema de misiones.

---

### Epic E05 — Misiones tutorial (Fase 1) — una US por misión

#### US-050 — Misión 1: Bienvenida manual (`quest_welcome_manual`)
*Como* jugador nuevo,
*quiero* una introducción manual al pueblo y controles,
*para* entender el mundo antes de programar.

**Criterios de aceptación:**
1. Hablar con NPC guía o llegar a cartel.
2. Textos i18n ES/EN.
3. Desbloquea acceso al editor (sin API aún).

**Dependencias:** US-012.

---

#### US-051 — Misión 2: Variables (`quest_variables_state`)
*Como* jugador que aprende,
*quiero* una misión que exija usar variables con HP, mana y posición,
*para* practicar estado en Lua.

**Criterios de aceptación:**
1. Plantilla con TODOs; checks de variables y `getPosition`.
2. Desbloquea getters base.
3. Feedback ante `nil` index.

**Dependencias:** US-031, US-032.

---

#### US-052 — Misión 3: Condicionales (`quest_if_safe_or_heal`)
*Como* jugador que aprende,
*quiero* usar `if/else` para decidir curar o moverme,
*para* entender ramas de decisión.

**Criterios de aceptación:**
1. Validación de bloque if/else y acciones por rama.
2. Desbloquea `move(dir)` y `usePotion` tutorial.
3. Simulación HP bajo/alto en tests de misión.

**Dependencias:** US-051.

---

#### US-053 — Misión 4: Ciclos (`quest_loop_patrol`)
*Como* jugador que aprende,
*quiero* patrullar con `for` o `while`,
*para* repetir acciones sin copiar código.

**Criterios de aceptación:**
1. Detecta al menos un loop; anti-infinito.
2. Patrulla en área acotada sin softlock.
3. Desbloquea validación de loops.

**Dependencias:** US-052.

---

#### US-054 — Misión 5: Funciones (`quest_function_move_to_flag`)
*Como* jugador que aprende,
*quiero* definir y llamar una función que use `moveTo`,
*para* organizar código reutilizable.

**Criterios de aceptación:**
1. Requiere `function` + llamada.
2. Llega a bandera con `moveTo(x,y)`.
3. Desbloquea `moveTo`, `isTileWalkable`.

**Dependencias:** US-053.

---

#### US-055 — Misiones 6–10 (inventario, kite, pociones, tienda, bandido)
*Como* jugador,
*quiero* completar el arco tutorial restante hasta el capítulo 1,
*para* dominar API de combate, economía y equipo.

**Descripción:** Implementar `quest_inventory_caps`, `quest_kite_wolf`, `quest_use_potions`, `quest_shop_loop`, `quest_bandit_mini` según tabla del plan.

**Criterios de aceptación:**
1. Cada misión con objetivos, plantilla y desbloqueo API indicado en plan.
2. Misión 10 cierra capítulo (bandido + entrega).
3. Progresión guardada en save local.

**Dependencias:** US-054, US-020–023, US-042.

**Notas:** puede dividirse en 5 Issues hijas si prefieres granularidad.

---

### Epic E06 — Internacionalización (Fase 0–1)

#### US-060 — i18n ES/EN en UI y misiones
*Como* jugador,
*quiero* UI y textos de misiones en español e inglés,
*para* audiencia internacional desde MVP.

**Criterios de aceptación:**
1. Sistema Godot Translation o CSV/JSON de keys.
2. Sin strings hardcodeados en escenas críticas.
3. Keys para errores Lua (`lua.error.*`).

**Dependencias:** US-001.

---

### Epic E07 — Backend Node.js (Fase 2)

#### US-070 — API auth y perfil
*Como* jugador registrado,
*quiero* cuenta con login y perfil (clase, preferencias),
*para* identidad persistente y cloud save.

**Criterios de aceptación:**
1. `POST /v1/auth/register`, `POST /v1/auth/login`.
2. `GET/PUT /v1/profile/me`.
3. Password hash seguro; JWT o sesiones documentadas.

**Dependencias:** US-001, PostgreSQL.

---

#### US-071 — Cloud save
*Como* jugador,
*quiero* guardar y cargar progreso en servidor,
*para* no perder nivel, inventario y misiones.

**Criterios de aceptación:**
1. `GET/PUT /v1/save` con `save_version`.
2. Validación básica anti-datos imposibles.
3. Cliente sincroniza al login y tras hitos clave.

**Dependencias:** US-070.

---

#### US-072 — Sim worker y envío de intentos
*Como* jugador competitivo,
*quiero* enviar mi script y que el servidor simule el reto,
*para* obtener un score justo sin confiar en el cliente.

**Criterios de aceptación:**
1. `POST /v1/challenges/:id/attempts` encola simulación.
2. Worker Node ejecuta tick engine + Lua; status queued→completed.
3. Score nunca aceptado desde cliente.

**Dependencias:** US-030, US-070, esquema DB del plan.

---

### Epic E08 — Rankings por mapa (Fase 2)

#### US-080 — Leaderboards world_01 (6 tablas)
*Como* jugador,
*quiero* ver tops por mapa en oro, daño y kills en ligas Standard y Open,
*para* competir con scripts o con mi build.

**Descripción:** Ventana 5 min (3000 ticks); métricas `gold_farmed`, `damage_done`, `monsters_killed`; brackets `standard` (build fijo) y `open` (snapshot jugador).

**Criterios de aceptación:**
1. `GET /v1/challenges` lista retos por `map_id=world_01`.
2. Leaderboards por `metric_kind` + `bracket` con desempates del plan.
3. Standard ignora stats del cliente; Open usa snapshot servidor.
4. Sin recompensas de oro persistente por ranking en MVP online.

**Dependencias:** US-072.

---

#### US-081 — Challenge offline dummy (cliente)
*Como* jugador sin backend,
*quiero* practicar un reto local de 5 min con score en pantalla,
*para* probar scripts antes de Fase 2 online.

**Criterios de aceptación:**
1. Misma ventana 3000 ticks y métricas que online.
2. Score solo local; no sube a leaderboard.
3. Documentado como puente hasta US-080.

**Dependencias:** US-030, US-020.

---

### Epic E09 — Datos y balance (transversal)

#### US-090 — Pack de datos MVP JSON
*Como* desarrollador,
*quiero* monsters, items, quests, shop y spawns en JSON,
*para* balancear sin recompilar.

**Criterios de aceptación:**
1. Archivos en `data/mvp/` cargados al inicio.
2. Hot-reload en editor debug (opcional).
3. Coherente con tablas del plan.

**Dependencias:** US-001.

---

### Orden sugerido de implementación (P0)
1. US-001 → US-002 → US-010 → US-011 → US-012 → US-090  
2. US-030 → US-031 → US-051–054 (tutorial código)  
3. US-020–023 → US-040–042 → US-055  
4. US-060 → US-043  
5. Fase 2: US-070 → US-071 → US-072 → US-081 → US-080  

---

### Mapeo Issue title → GitHub
| ID | Título Issue sugerido |
| --- | --- |
| US-001 | chore: init monorepo + docs/plan.md |
| US-010 | feat(client): tick engine 10 TPS |
| US-030 | feat(client): Lua sandbox + API MVP |
| US-031 | feat(client): in-game code editor |
| US-080 | feat(server): world_01 leaderboards 6 boards |
