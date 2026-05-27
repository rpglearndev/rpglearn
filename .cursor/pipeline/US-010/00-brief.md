# US-010 — Brief

## Como / quiero / para

*Como* jugador (y simulador futuro),
*quiero* que el mundo avance en ticks fijos de 100 ms,
*para* que combate, movimiento y scripts sean predecibles y reproducibles.

## Descripción

Implementar `TickWorld` en cliente: contador global, cola de acciones, 1 acción mayor por tick, coste 1 tick por tile al mover.

## Criterios de aceptación

1. Tickrate configurable; default 10 TPS.
2. Movimiento discreto N/S/E/W consume 1 tick y mueve 1 tile si es walkable.
3. Tests unitarios o escena debug muestran mismo resultado con misma secuencia de inputs.
4. Sin dependencia de `delta` real para lógica de juego.

## Dependencias

US-001, proyecto Godot base.

## Notas

Base para ranking servidor.
