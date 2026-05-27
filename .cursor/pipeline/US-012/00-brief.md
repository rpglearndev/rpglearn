# US-012 — Brief

## Como / quiero / para

*Como* jugador,
*quiero* un mapa con Greenfield, Riverton y Outskirts,
*para* explorar, farmear y hacer misiones tutorial.

## Criterios de aceptación

1. TileMap 32×32 con assets Mixel; filtro Nearest.
2. Zonas lógicas identificadas (metadata o layers).
3. Área de práctica acotada para misiones de código.
4. Y-sort en capa de entidades.

## Dependencias

US-001, assets Mixel importados.

## Notas implementación

- Placeholder procedural tipo Mixel hasta importar pack real en `assets/mixel/`.
- Mapa único `world_01` con tres zonas por rectángulos lógicos + capa de tiles.
