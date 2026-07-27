extends Control


@onready var earth_button: Button = $MapContainer/EarthButton
@onready var air_button: Button = $MapContainer/AirButton
@onready var water_button: Button = $MapContainer/WaterButton
@onready var fire_button: Button = $MapContainer/FireButton
@onready var status_label: Label = $StatusLabel


func _ready() -> void:
	earth_button.pressed.connect(_on_earth_pressed)
	air_button.pressed.connect(_on_air_pressed)
	water_button.pressed.connect(_on_water_pressed)
	fire_button.pressed.connect(_on_fire_pressed)
	_refresh_map()


func _refresh_map() -> void:
	earth_button.disabled = not GameManager.is_level_unlocked("earth")
	air_button.disabled = not GameManager.is_level_unlocked("air")
	water_button.disabled = not GameManager.is_level_unlocked("water")
	fire_button.disabled = not GameManager.is_level_unlocked("fire")

	earth_button.text = "Tierra%s" % (" ✓" if GameManager.is_level_completed("earth") else "")
	air_button.text = "Aire%s" % (" ✓" if GameManager.is_level_completed("air") else (" (bloqueado)" if air_button.disabled else ""))
	water_button.text = "Agua%s" % (" ✓" if GameManager.is_level_completed("water") else (" (bloqueado)" if water_button.disabled else ""))
	fire_button.text = "Fuego%s" % (" ✓" if GameManager.is_level_completed("fire") else (" (bloqueado)" if fire_button.disabled else ""))

	status_label.text = "Vidas: %d | Gemas: %d | Puntaje: %d" % [
		GameManager.lives,
		GameManager.gems,
		GameManager.score,
	]


func _on_earth_pressed() -> void:
	GameManager.load_level("earth")


func _on_air_pressed() -> void:
	GameManager.load_level("air")


func _on_water_pressed() -> void:
	GameManager.load_level("water")


func _on_fire_pressed() -> void:
	GameManager.load_level("fire")
