extends Control


func _ready() -> void:
	$VBox/RetryButton.pressed.connect(_on_retry_pressed)
	$VBox/MenuButton.pressed.connect(_on_menu_pressed)

	# Load defeat image, remove background and show it above the buttons
	var frames := GameManager.cargar_sprite_sin_fondo("res://sprites/death.png")
	if frames:
		var anim := AnimatedSprite2D.new()
		anim.sprite_frames = frames
		anim.animation = "default"
		anim.play()
		anim.scale = Vector2(2, 2)
		$VBox.add_child(anim)
		$VBox.move_child(anim, 0)


func _on_retry_pressed() -> void:
	# Retry the same combat: reload current level and set combat state
	GameManager.current_state = GameManager.GameState.COMBAT
	GameManager.load_level(GameManager.current_level_id)


func _on_menu_pressed() -> void:
	GameManager.current_state = GameManager.GameState.MENU
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
