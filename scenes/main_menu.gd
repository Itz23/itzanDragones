extends Control


func _ready() -> void:
	$VBox/StartMediumButton.pressed.connect(_on_start_medium_pressed)
	$VBox/StartHardButton.pressed.connect(_on_start_hard_pressed)
	$VBox/QuitButton.pressed.connect(_on_quit_pressed)


func _on_start_medium_pressed() -> void:
	GameManager.start_new_game(GameManager.Difficulty.MEDIA)


func _on_start_hard_pressed() -> void:
	GameManager.start_new_game(GameManager.Difficulty.DIFICIL)


func _on_quit_pressed() -> void:
	get_tree().quit()
