extends CharacterBody2D

var speed = 200.0
var jump_force = 450.0

func _physics_process(delta):
	# 1. Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Input y Movimiento
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	# 3. Animación (TODO ESTO DEBE ESTAR DENTRO DE LA FUNCIÓN)
	if direction != 0:
		$AnimatedSprite2D.play("default")
		
		if direction < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.stop()

	# 4. Mover el personaje (DEBE SER LA ÚLTIMA LÍNEA DE LA FUNCIÓN)
	move_and_slide()   
