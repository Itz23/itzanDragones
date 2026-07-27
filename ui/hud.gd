extends Control


@onready var lives_label: Label = $Margin/VBox/LivesRow/LivesLabel
@onready var score_label: Label = $Margin/VBox/ScoreLabel
@onready var gems_label: Label = $Margin/VBox/GemsLabel
@onready var health_bar: ProgressBar = $Margin/VBox/HealthBar


func _ready() -> void:
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.gems_changed.connect(_on_gems_changed)
	GameManager.health_changed.connect(_on_health_changed)
	_refresh_all()


func _refresh_all() -> void:
	_on_lives_changed(GameManager.lives)
	_on_score_changed(GameManager.score)
	_on_gems_changed(GameManager.gems)
	_on_health_changed(GameManager.health, GameManager.MAX_HEALTH)


func _on_lives_changed(current_lives: int) -> void:
	lives_label.text = "Vidas: %d" % current_lives


func _on_score_changed(current_score: int) -> void:
	score_label.text = "Puntaje: %d" % current_score


func _on_gems_changed(current_gems: int) -> void:
	gems_label.text = "Gemas: %d" % current_gems


func _on_health_changed(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
