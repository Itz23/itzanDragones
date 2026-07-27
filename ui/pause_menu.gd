extends CanvasLayer


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/ResumeButton.pressed.connect(_on_resume_pressed)
	$Panel/QuitButton.pressed.connect(_on_quit_pressed)


func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_quit_pressed() -> void:
	get_tree().paused = false
	GameManager.return_to_map()
