extends Control

func _ready() -> void:
	var dragon_name := _get_dragon_name(GameManager.current_level_id)
	$VBox/Message.text = "¡Derrotaste al Dragón de %s!" % dragon_name
	$VBox/Stats.text = "Puntaje: %d | Gemas: %d" % [GameManager.score, GameManager.gems]

	var frames := GameManager.cargar_sprite_sin_fondo("res://sprites/victory.png")
	if frames:
		$VictorySprite.sprite_frames = frames
		$VictorySprite.animation = "default"
		$VictorySprite.play()

	$VBox/ContinueButton.pressed.connect(_on_continue_pressed)

func _get_dragon_name(level_id: String) -> String:
	match level_id:
		"earth":
			return "Tierra"
		"air":
			return "Aire"
		"water":
			return "Agua"
		"fire":
			return "Fuego"
	return "?"

func _on_continue_pressed() -> void:
	GameManager.save_progress()
	GameManager.current_state = GameManager.GameState.MAP
	GameManager.return_to_map()
