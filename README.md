# Iltzan y los Dragones Elementales

Videojuego 2D de acción, aventura y plataformas desarrollado en **Godot Engine 4.7** con **GDScript**.

## Cómo abrir el proyecto

1. Instala [Godot 4.7](https://godotengine.org/download).
2. Abre Godot y selecciona **Importar**.
3. Elige la carpeta `C:\cursorItzan` y el archivo `project.godot`.
4. Pulsa **Ejecutar proyecto** (F5).

## Controles

| Tecla | Acción |
|-------|--------|
| ← → | Caminar |
| ↑ | Saltar (doble salto tras vencer al dragón de Aire) |
| ↓ | Agacharse |
| A | Ataque con espada |
| W | Espada de fuego (tras vencer al dragón de Fuego) |
| S | Escudo de piedra (tras vencer al dragón de Fuego) |
| P | Pausa |
| Doble toque ←/→ | Dash (tras vencer al dragón de Agua) |

## Mecánicas implementadas (beta)

- Menú principal y mapa del mundo
- Nivel de Tierra jugable con enemigos, gemas, pociones y jefe
- Movimiento, salto, agacharse, ataque
- Sistema de 3 vidas (pierdes una vida por golpe)
- Game Over al quedarte sin vidas
- Recolección de gemas y recuperación con pociones
- Colisiones: suelo, enemigos, objetos y obstáculos
- Progresión por dragones elementales

## Arte del personaje

Los sprites de **Iltzan** están en `assets/player/` y las animaciones en `player/iltzan_sprite_frames.tres`.
Para regenerarlos desde las hojas en `_extract/itzan sprites/`:

```
python assets/player/_build_sprites.py
python assets/player/_gen_sprite_frames.py
```

Otros elementos (enemigos, objetos) siguen usando placeholders de colores.

## Estructura del proyecto

```
autoload/          Estado global (vidas, puntaje, progreso)
player/            Personaje Iltzan
enemies/           Enemigos y dragones
objects/           Gemas, pociones, plataformas, peligros
scenes/            Menús, mapa y niveles
ui/                HUD y pausa
scripts/           Lógica compartida de niveles y cámara
```
