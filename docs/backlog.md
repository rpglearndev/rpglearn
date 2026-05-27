## Backlog â€” User Stories (formato GitHub)

Cada Ã­tem abajo es una **Issue** lista para pegar. IDs: `US-001` â€¦

---

### Epic E00 â€” Repositorio, documentaciÃ³n y convenciones

#### US-001 â€” Inicializar monorepo y documentaciÃ³n
*Como* desarrollador del proyecto,
*quiero* un repositorio en la org `rpglearndev` con estructura de carpetas y `docs/plan.md`,
*para* tener una base versionada antes de escribir cÃ³digo de juego.

**DescripciÃ³n:**
Crear repo `rpglearn`, README mÃ­nimo, `.gitignore` (Godot, Node, env), subir `plan.md` y `backlog.md`, definir licencia del cÃ³digo propio y `CREDITS.md` para assets (Mixel, DB32 CC0).

**Criterios de aceptaciÃ³n:**
1. Repo accesible en `github.com/rpglearndev/rpglearn` (o nombre acordado).
2. Existe `docs/plan.md` alineado con este documento.
3. README explica cÃ³mo abrir cliente Godot y (futuro) servidor.
4. `CREDITS.md` lista fuentes de assets y licencias.

**Dependencias:** ninguna.

**Notas:** org ya creada; sin repos pÃºblicos aÃºn.

---

#### US-002 â€” GitHub Project y plantilla de Issue
*Como* desarrollador,
*quiero* un Project board y plantilla de Issue con secciones Como/Quiero/Para y criterios,
*para* gestionar el MVP sin perder el formato de historias.

**Criterios de aceptaciÃ³n:**
1. Project *MVP Roadmap* con columnas definidas.
2. Plantilla `.github/ISSUE_TEMPLATE/user_story.md` (opcional feature request).
3. Labels `epic/*`, `phase-*`, `area/*` creados.

**Dependencias:** US-001.

---

### Epic E01 â€” Motor de ticks y movimiento (Fase 0)

#### US-010 â€” Tick engine determinista (10 TPS)
*Como* jugador (y simulador futuro),
*quiero* que el mundo avance en ticks fijos de 100 ms,
*para* que combate, movimiento y scripts sean predecibles y reproducibles.

**DescripciÃ³n:**
Implementar `TickWorld` en cliente: contador global, cola de acciones, 1 acciÃ³n mayor por tick, coste 1 tick por tile al mover.

**Criterios de aceptaciÃ³n:**
1. Tickrate configurable; default 10 TPS.
2. Movimiento discreto N/S/E/W consume 1 tick y mueve 1 tile si es walkable.
3. Tests unitarios o escena debug muestran mismo resultado con misma secuencia de inputs.
4. Sin dependencia de `delta` real para lÃ³gica de juego.

**Dependencias:** US-001, proyecto Godot base.

**Notas:** base para ranking servidor.

---

#### US-011 â€” Input manual WASD y joystick
*Como* jugador,
*quiero* controlar al personaje con teclado o joystick ademÃ¡s del bot Lua,
*para* aprender manualmente y retomar control si el script falla.

**Criterios de aceptaciÃ³n:**
1. WASD mueve 1 tile por pulsaciÃ³n (o por tick segÃºn diseÃ±o acordado).
2. Joystick virtual en mÃ³vil (stub o implementaciÃ³n mÃ­nima en desktop).
3. Modo manual anula acciones del script en el mismo tick (prioridad manual).

**Dependencias:** US-010.

---

#### US-012 â€” Mapa World_01 con TileMap 32Ã—32
*Como* jugador,
*quiero* un mapa con Greenfield, Riverton y Outskirts,
*para* explorar, farmear y hacer misiones tutorial.

**Criterios de aceptaciÃ³n:**
1. TileMap 32Ã—32 con assets Mixel; filtro Nearest.
2. Zonas lÃ³gicas identificadas (metadata o layers).
3. Ãrea de prÃ¡ctica acotada para misiones de cÃ³digo.
4. Y-sort en capa de entidades.

**Dependencias:** US-001, assets Mixel importados.

---

### Epic E02 â€” Combate, loot y economÃ­a bÃ¡sica (Fase 0)

#### US-020 â€” Combate melee y ranged por ticks
*Como* jugador,
*quiero* atacar enemigos respetando cooldown y rango (sin LoS),
*para* farmear y completar misiones de combate.

**Criterios de aceptaciÃ³n:**
1. `attack` valida rango; mago/arquero usan `setDesiredRange`.
2. DaÃ±o usa fÃ³rmula parametrizada (JSON).
3. Enemigo puede morir; XP/oro segÃºn `monsters.json`.

**Dependencias:** US-010, US-030 (datos monstruos).

---

#### US-021 â€” Tres monstruos MVP y spawns
*Como* jugador,
*quiero* slime, lobo y bandido con dificultad creciente,
*para* progresiÃ³n de combate y tutorial.

**Criterios de aceptaciÃ³n:**
1. `mob_slime`, `mob_wolf`, `mob_bandit` en `data/mvp/monsters.json` + spawns.
2. RelaciÃ³n de poder: slime < wolf < bandit.
3. Drops bÃ¡sicos (oro, chatarra vendible).

**Dependencias:** US-012.

---

#### US-022 â€” Loot, inventario y capacidad
*Como* jugador,
*quiero* recoger loot y ver peso/capacidad,
*para* gestionar farm y misiones de inventario.

**Criterios de aceptaciÃ³n:**
1. `loot()` en tile actual aÃ±ade Ã­tems/oro.
2. `getInventory`, `getCapacity`, `getCarryWeight` reflejan estado real.
3. No se puede recoger si excede capacidad.

**Dependencias:** US-020, Ã­tems DB32 mapeados.

---

#### US-023 â€” Tienda Riverton (buy/sell)
*Como* jugador,
*quiero* vender loot y comprar pociones en el pueblo,
*para* economÃ­a loop y misiÃ³n de tienda.

**Criterios de aceptaciÃ³n:**
1. NPC shop en Riverton; UI o interacciÃ³n por tile.
2. `buy`/`sell` vÃ­a Lua y manual (misma lÃ³gica).
3. Precios en `data/mvp/shop.json`.

**Dependencias:** US-022, US-012.

---

### Epic E03 â€” Lua sandbox y editor (Fase 0â€“1)

#### US-030 â€” Runtime Lua embebido con sandbox
*Como* jugador que aprende a programar,
*quiero* ejecutar scripts Lua con API limitada del juego,
*para* automatizar acciones sin riesgos de seguridad.

**DescripciÃ³n:**
Integrar Lua en Godot; bloquear `os`, `io`, red; whitelist de funciones; watchdog de instrucciones; 1 acciÃ³n mayor/tick.

**Criterios de aceptaciÃ³n:**
1. Script corre en sandbox; errores capturados con lÃ­nea.
2. API MVP expuesta segÃºn desbloqueos de misiÃ³n.
3. `moveTo` usa A* completo; falla controlado sin path.
4. RNG solo vÃ­a API del motor con seed fija en modo reto.

**Dependencias:** US-010.

---

#### US-031 â€” Editor de cÃ³digo in-game
*Como* jugador,
*quiero* un editor con Run/Stop, plantillas y consola,
*para* escribir y depurar scripts dentro del juego.

**Criterios de aceptaciÃ³n:**
1. `CodeEdit` o equivalente; botones Run/Stop.
2. Consola muestra salida y errores traducibles (i18n keys).
3. Plantillas por `quest_id` cargadas desde datos.
4. Override manual disponible si script falla.

**Dependencias:** US-030.

---

#### US-032 â€” Validador pedagÃ³gico misiones 2â€“5
*Como* jugador principiante,
*quiero* feedback si mi script usa variables, if, loops o funciones correctamente,
*para* aprender como en un curso real.

**Criterios de aceptaciÃ³n:**
1. Checks por misiÃ³n segÃºn secciÃ³n "Plantillas y validaciÃ³n didÃ¡ctica".
2. Mensajes: quÃ© faltÃ³, ejemplo mÃ­nimo, pista.
3. Detectar loop infinito / timeout.

**Dependencias:** US-031, misiones definidas en `quests.json`.

---

### Epic E04 â€” Clases, skills y equipo (Fase 1)

#### US-040 â€” SelecciÃ³n de clase y equipo inicial
*Como* jugador nuevo,
*quiero* elegir Guerrero, Mago o Arquero con equipo inicial,
*para* empezar con identidad de rol.

**Criterios de aceptaciÃ³n:**
1. Pantalla creaciÃ³n: nombre + clase.
2. Equipo inicial segÃºn tabla del plan (`wpn_*`, `arm_cloth_tunic`, etc.).
3. Stats derivados de equipo visible en UI.

**Dependencias:** US-022, `items.json`.

---

#### US-041 â€” Skills por uso con anti-farm (N=10)
*Como* jugador,
*quiero* que melee/ranged/magic suban al usar armas, con tope si no acierto,
*para* evitar subir skill contra enemigos imposibles.

**Criterios de aceptaciÃ³n:**
1. XP por intento de ataque; stop tras 10 intentos sin hit global hasta 1 hit.
2. Curva de nivel de skill parametrizada.
3. DaÃ±o escala con skill + arma + nivel.

**Dependencias:** US-020.

---

#### US-042 â€” Equipamiento (slots y stats atk/def)
*Como* jugador,
*quiero* equipar arma, escudo, casco, armadura y botas,
*para* progresar con loot y tienda.

**Criterios de aceptaciÃ³n:**
1. Slots definidos; `equip`/`unequip` manual y Lua.
2. Solo `attack`/`defense` + `levelReq` en MVP.
3. Iconos DB32 en UI (16â†’32 Nearest).

**Dependencias:** US-040, US-022.

---

#### US-043 â€” Saltar tutorial (jugador avanzado)
*Como* jugador que ya sabe programar,
*quiero* saltar el tutorial y tener API completa desbloqueada,
*para* jugar sin fricciÃ³n pedagÃ³gica.

**Criterios de aceptaciÃ³n:**
1. OpciÃ³n en menÃº con confirmaciÃ³n.
2. Marca misiones 2â€“10 completadas localmente; desbloquea API MVP.
3. No afecta rankings Standard (build fijo).

**Dependencias:** US-032, sistema de misiones.

---

### Epic E05 â€” Misiones tutorial (Fase 1) â€” una US por misiÃ³n

#### US-050 â€” MisiÃ³n 1: Bienvenida manual (`quest_welcome_manual`)
*Como* jugador nuevo,
*quiero* una introducciÃ³n manual al pueblo y controles,
*para* entender el mundo antes de programar.

**Criterios de aceptaciÃ³n:**
1. Hablar con NPC guÃ­a o llegar a cartel.
2. Textos i18n ES/EN.
3. Desbloquea acceso al editor (sin API aÃºn).

**Dependencias:** US-012.

---

#### US-051 â€” MisiÃ³n 2: Variables (`quest_variables_state`)
*Como* jugador que aprende,
*quiero* una misiÃ³n que exija usar variables con HP, mana y posiciÃ³n,
*para* practicar estado en Lua.

**Criterios de aceptaciÃ³n:**
1. Plantilla con TODOs; checks de variables y `getPosition`.
2. Desbloquea getters base.
3. Feedback ante `nil` index.

**Dependencias:** US-031, US-032.

---

#### US-052 â€” MisiÃ³n 3: Condicionales (`quest_if_safe_or_heal`)
*Como* jugador que aprende,
*quiero* usar `if/else` para decidir curar o moverme,
*para* entender ramas de decisiÃ³n.

**Criterios de aceptaciÃ³n:**
1. ValidaciÃ³n de bloque if/else y acciones por rama.
2. Desbloquea `move(dir)` y `usePotion` tutorial.
3. SimulaciÃ³n HP bajo/alto en tests de misiÃ³n.

**Dependencias:** US-051.

---

#### US-053 â€” MisiÃ³n 4: Ciclos (`quest_loop_patrol`)
*Como* jugador que aprende,
*quiero* patrullar con `for` o `while`,
*para* repetir acciones sin copiar cÃ³digo.

**Criterios de aceptaciÃ³n:**
1. Detecta al menos un loop; anti-infinito.
2. Patrulla en Ã¡rea acotada sin softlock.
3. Desbloquea validaciÃ³n de loops.

**Dependencias:** US-052.

---

#### US-054 â€” MisiÃ³n 5: Funciones (`quest_function_move_to_flag`)
*Como* jugador que aprende,
*quiero* definir y llamar una funciÃ³n que use `moveTo`,
*para* organizar cÃ³digo reutilizable.

**Criterios de aceptaciÃ³n:**
1. Requiere `function` + llamada.
2. Llega a bandera con `moveTo(x,y)`.
3. Desbloquea `moveTo`, `isTileWalkable`.

**Dependencias:** US-053.

---

#### US-055 â€” Misiones 6â€“10 (inventario, kite, pociones, tienda, bandido)
*Como* jugador,
*quiero* completar el arco tutorial restante hasta el capÃ­tulo 1,
*para* dominar API de combate, economÃ­a y equipo.

**DescripciÃ³n:** Implementar `quest_inventory_caps`, `quest_kite_wolf`, `quest_use_potions`, `quest_shop_loop`, `quest_bandit_mini` segÃºn tabla del plan.

**Criterios de aceptaciÃ³n:**
1. Cada misiÃ³n con objetivos, plantilla y desbloqueo API indicado en plan.
2. MisiÃ³n 10 cierra capÃ­tulo (bandido + entrega).
3. ProgresiÃ³n guardada en save local.

**Dependencias:** US-054, US-020â€“023, US-042.

**Notas:** puede dividirse en 5 Issues hijas si prefieres granularidad.

---

### Epic E06 â€” InternacionalizaciÃ³n (Fase 0â€“1)

#### US-060 â€” i18n ES/EN en UI y misiones
*Como* jugador,
*quiero* UI y textos de misiones en espaÃ±ol e inglÃ©s,
*para* audiencia internacional desde MVP.

**Criterios de aceptaciÃ³n:**
1. Sistema Godot Translation o CSV/JSON de keys.
2. Sin strings hardcodeados en escenas crÃ­ticas.
3. Keys para errores Lua (`lua.error.*`).

**Dependencias:** US-001.

---

### Epic E07 â€” Backend Node.js (Fase 2)

#### US-070 â€” API auth y perfil
*Como* jugador registrado,
*quiero* cuenta con login y perfil (clase, preferencias),
*para* identidad persistente y cloud save.

**Criterios de aceptaciÃ³n:**
1. `POST /v1/auth/register`, `POST /v1/auth/login`.
2. `GET/PUT /v1/profile/me`.
3. Password hash seguro; JWT o sesiones documentadas.

**Dependencias:** US-001, PostgreSQL.

---

#### US-071 â€” Cloud save
*Como* jugador,
*quiero* guardar y cargar progreso en servidor,
*para* no perder nivel, inventario y misiones.

**Criterios de aceptaciÃ³n:**
1. `GET/PUT /v1/save` con `save_version`.
2. ValidaciÃ³n bÃ¡sica anti-datos imposibles.
3. Cliente sincroniza al login y tras hitos clave.

**Dependencias:** US-070.

---

#### US-072 â€” Sim worker y envÃ­o de intentos
*Como* jugador competitivo,
*quiero* enviar mi script y que el servidor simule el reto,
*para* obtener un score justo sin confiar en el cliente.

**Criterios de aceptaciÃ³n:**
1. `POST /v1/challenges/:id/attempts` encola simulaciÃ³n.
2. Worker Node ejecuta tick engine + Lua; status queuedâ†’completed.
3. Score nunca aceptado desde cliente.

**Dependencias:** US-030, US-070, esquema DB del plan.

---

### Epic E08 â€” Rankings por mapa (Fase 2)

#### US-080 â€” Leaderboards world_01 (6 tablas)
*Como* jugador,
*quiero* ver tops por mapa en oro, daÃ±o y kills en ligas Standard y Open,
*para* competir con scripts o con mi build.

**DescripciÃ³n:** Ventana 5 min (3000 ticks); mÃ©tricas `gold_farmed`, `damage_done`, `monsters_killed`; brackets `standard` (build fijo) y `open` (snapshot jugador).

**Criterios de aceptaciÃ³n:**
1. `GET /v1/challenges` lista retos por `map_id=world_01`.
2. Leaderboards por `metric_kind` + `bracket` con desempates del plan.
3. Standard ignora stats del cliente; Open usa snapshot servidor.
4. Sin recompensas de oro persistente por ranking en MVP online.

**Dependencias:** US-072.

---

#### US-081 â€” Challenge offline dummy (cliente)
*Como* jugador sin backend,
*quiero* practicar un reto local de 5 min con score en pantalla,
*para* probar scripts antes de Fase 2 online.

**Criterios de aceptaciÃ³n:**
1. Misma ventana 3000 ticks y mÃ©tricas que online.
2. Score solo local; no sube a leaderboard.
3. Documentado como puente hasta US-080.

**Dependencias:** US-030, US-020.

---

### Epic E09 â€” Datos y balance (transversal)

#### US-090 â€” Pack de datos MVP JSON
*Como* desarrollador,
*quiero* monsters, items, quests, shop y spawns en JSON,
*para* balancear sin recompilar.

**Criterios de aceptaciÃ³n:**
1. Archivos en `data/mvp/` cargados al inicio.
2. Hot-reload en editor debug (opcional).
3. Coherente con tablas del plan.

**Dependencias:** US-001.

---

### Orden sugerido de implementaciÃ³n (P0)
1. US-001 â†’ US-002 â†’ US-010 â†’ US-011 â†’ US-012 â†’ US-090  
2. US-030 â†’ US-031 â†’ US-051â€“054 (tutorial cÃ³digo)  
3. US-020â€“023 â†’ US-040â€“042 â†’ US-055  
4. US-060 â†’ US-043  
5. Fase 2: US-070 â†’ US-071 â†’ US-072 â†’ US-081 â†’ US-080  

---

### Mapeo Issue title â†’ GitHub
| ID | TÃ­tulo Issue sugerido |
| --- | --- |
| US-001 | chore: init monorepo + docs/plan.md |
| US-010 | feat(client): tick engine 10 TPS |
| US-030 | feat(client): Lua sandbox + API MVP |
| US-031 | feat(client): in-game code editor |
| US-080 | feat(server): world_01 leaderboards 6 boards |

