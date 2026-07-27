extends Control


func _ready() -> void:
	$VBox/RetryButton.pressed.connect(_on_retry_pressed)
	$VBox/MenuButton.pressed.connect(_on_menu_pressed)


func _on_retry_pressed() -> void:
	GameManager.reset_run()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_menu_pressed() -> void:
	GameManager.reset_run()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
