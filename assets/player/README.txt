Sprites del personaje Iltzan
============================

Coloca aquí los PNG del personaje. Nombres esperados:

  iltzan_idle.png       — quieto (28×44 px)
  iltzan_run_1.png      — correr, frame 1
  iltzan_run_2.png      — correr, frame 2
  iltzan_jump.png       — salto (28×44 px)
  iltzan_fall.png       — caída (28×44 px)
  iltzan_crouch.png     — agachado (28×24 px)
  iltzan_attack_1.png   — ataque normal
  iltzan_attack_2.png   — ataque de fuego
  iltzan_dash.png       — dash
  iltzan_hurt.png       — daño recibido
  iltzan_victory_1..6   — animación de victoria (6 frames)

Hoja original de victoria:
  _extract/itzan sprites/victory.png

Regenerar sprites desde las hojas:
  python assets/player/_build_sprites.py
  python assets/player/_gen_sprite_frames.py

También puedes subir un .zip con las imágenes; se reemplazarán
los placeholders actuales manteniendo estos nombres.

Configuración recomendada en Godot (Import):
  - Filter: Nearest (pixel art)
  - Mipmaps: desactivados

Las animaciones están definidas en:
  res://player/iltzan_sprite_frames.tres
