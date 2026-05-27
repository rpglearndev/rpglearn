# Mixel world tiles (32×32)

Pack: [Free Top-Down RPG 32×32 by Mixel](https://mixelslime.itch.io/free-top-down-rpg-32x32-tile-set) (ZIP de PNG).

## Godot

```powershell
.\scripts\link_mixel_assets.ps1
```

El cliente usa `res://assets/mixel/` (junction → esta carpeta).

### Integración en World_01

| Sistema | Archivo |
|---------|---------|
| Autotile césped/camino | `mixel_ground_terrain_setup.gd` + `set_cells_terrain_connect` |
| Ruinas Riverton | `Buildings v.1.1/... Ruins.PNG` |
| Vallas práctica | `Rocks 1.2.PNG` |
| Decoración | `Nature Details` + `Trees 1.2` |
| Personaje | `MainCharacter v.1.0/MainC_Idle_Front.PNG` |

**Nota:** el ZIP “Godot 4.2 Ready” trae TileSets ya configurados; aquí se monta el terreno por código para el MVP sin copiar ese proyecto entero.

Para un mapa artístico final, conviene abrir el pack Ready en el editor y exportar un `.tres`, o pintar en el editor con Terrains.
