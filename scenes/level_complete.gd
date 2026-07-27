extends Control


func _ready() -> void:
	var dragon_name := _get_dragon_name(GameManager.current_level_id)
	$VBox/Message.text = "¡Derrotaste al Dragón de %s!" % dragon_name
	$VBox/Stats.text = "Puntaje: %d | Gemas: %d" % [GameManager.score, GameManager.gems]
	$VBox/MapButton.pressed.connect(_on_map_pressed)


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


func _on_map_pressed() -> void:
	GameManager.return_to_map()
