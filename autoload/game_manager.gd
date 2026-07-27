extends Node

signal lives_changed(current_lives: int)
signal score_changed(current_score: int)
signal gems_changed(current_gems: int)
signal health_changed(current_health: int, max_health: int)
signal dragon_defeated(dragon_id: String)

enum Difficulty { MEDIA, DIFICIL }

const MAX_LIVES := 3
const MAX_HEALTH := 100
const LEVEL_PATHS := {
	"earth": "res://scenes/levels/level_earth.tscn",
	"air": "res://scenes/levels/level_air.tscn",
	"water": "res://scenes/levels/level_water.tscn",
	"fire": "res://scenes/levels/level_fire.tscn",
}

var difficulty: Difficulty = Difficulty.MEDIA
var lives: int = MAX_LIVES
var score: int = 0
var gems: int = 0
var health: int = MAX_HEALTH

var earth_dragon_defeated := false
var air_dragon_defeated := false
var water_dragon_defeated := false
var fire_dragon_defeated := false

var has_double_jump := false
var has_dash := false
var has_fire_sword := false
var has_stone_shield := false

var current_level_id: String = ""


func reset_run() -> void:
	difficulty = Difficulty.MEDIA
	lives = MAX_LIVES
	score = 0
	gems = 0
	health = MAX_HEALTH
	earth_dragon_defeated = false
	air_dragon_defeated = false
	water_dragon_defeated = false
	fire_dragon_defeated = false
	has_double_jump = false
	has_dash = false
	has_fire_sword = false
	has_stone_shield = false
	current_level_id = ""
	_emit_all()


func start_new_game(selected_difficulty: Difficulty) -> void:
	reset_run()
	difficulty = selected_difficulty
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")


func prepare_level(level_id: String) -> void:
	current_level_id = level_id
	health = MAX_HEALTH
	health_changed.emit(health, MAX_HEALTH)


func load_level(level_id: String) -> void:
	if not LEVEL_PATHS.has(level_id):
		push_error("Nivel desconocido: %s" % level_id)
		return
	prepare_level(level_id)
	get_tree().change_scene_to_file(LEVEL_PATHS[level_id])


func return_to_map() -> void:
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")


func show_game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func show_level_complete(level_id: String) -> void:
	match level_id:
		"earth":
			earth_dragon_defeated = true
		"air":
			air_dragon_defeated = true
			has_double_jump = true
		"water":
			water_dragon_defeated = true
			has_dash = true
		"fire":
			fire_dragon_defeated = true
			has_fire_sword = true
			has_stone_shield = true
	dragon_defeated.emit(level_id)
	get_tree().change_scene_to_file("res://scenes/level_complete.tscn")


func is_level_unlocked(level_id: String) -> bool:
	match level_id:
		"earth":
			return true
		"air":
			return earth_dragon_defeated
		"water":
			return air_dragon_defeated
		"fire":
			return water_dragon_defeated
	return false


func is_level_completed(level_id: String) -> bool:
	match level_id:
		"earth":
			return earth_dragon_defeated
		"air":
			return air_dragon_defeated
		"water":
			return water_dragon_defeated
		"fire":
			return fire_dragon_defeated
	return false


func lose_life() -> void:
	lives = max(lives - 1, 0)
	lives_changed.emit(lives)
	if lives <= 0:
		show_game_over()


func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


func add_gem() -> void:
	gems += 1
	add_score(50)
	gems_changed.emit(gems)


func heal(amount: int) -> void:
	health = clampi(health + amount, 0, MAX_HEALTH)
	health_changed.emit(health, MAX_HEALTH)


func take_damage(amount: int = 0) -> void:
	lose_life()
	health = MAX_HEALTH if lives > 0 else 0
	health_changed.emit(health, MAX_HEALTH)


func get_difficulty_label() -> String:
	return "Media" if difficulty == Difficulty.MEDIA else "Difícil"


func _emit_all() -> void:
	lives_changed.emit(lives)
	score_changed.emit(score)
	gems_changed.emit(gems)
	health_changed.emit(health, MAX_HEALTH)
