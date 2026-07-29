extends Control

func _ready() -> void:
	$VBox/Title.text = "DERROTA"
	$VBox/Message.text = "Has sido derrotado."

	var frames := GameManager.cargar_sprite_sin_fondo("res://sprites/death.png")
	if frames:
		$DefeatSprite.sprite_frames = frames
		$DefeatSprite.animation = "default"
		$DefeatSprite.play()

	$VBox/RetryButton.pressed.connect(_on_retry_pressed)
	$VBox/MenuButton.pressed.connect(_on_menu_pressed)

func _on_retry_pressed() -> void:
	# Reset lives and health for retry, then reload the same level
	GameManager.lives = GameManager.MAX_LIVES
	GameManager.prepare_level(GameManager.current_level_id)
	GameManager.current_state = GameManager.GameState.COMBAT
	GameManager.load_level(GameManager.current_level_id)

func _on_menu_pressed() -> void:
	GameManager.current_state = GameManager.GameState.MENU
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
