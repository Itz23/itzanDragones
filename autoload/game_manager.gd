extends Node

signal lives_changed(current_lives: int)
signal score_changed(current_score: int)
signal gems_changed(current_gems: int)
signal health_changed(current_health: int, max_health: int)
signal dragon_defeated(dragon_id: String)

enum Difficulty { MEDIA, DIFICIL }
enum GameState { MENU, MAP, COMBAT, VICTORY, DEFEAT }

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
var current_state: GameState = GameState.MENU


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
	current_state = GameState.DEFEAT
	var tree := get_tree()
	if tree:
		tree.call_deferred("change_scene_to_file", "res://scenes/defeat_screen.tscn")


func show_level_complete(level_id: String) -> void:
	# Mark dragon defeated and trigger victory flow
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
	# Switch to victory state and show victory scene (deferred to avoid physics-callback issues)
	current_state = GameState.VICTORY
	current_level_id = level_id
	var tree := get_tree()
	if tree:
		tree.call_deferred("change_scene_to_file", "res://scenes/victory_screen.tscn")


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
	if lives <= 0:
		current_state = GameState.DEFEAT


func get_difficulty_label() -> String:
	return "Media" if difficulty == Difficulty.MEDIA else "Difícil"


func _emit_all() -> void:
	lives_changed.emit(lives)
	score_changed.emit(score)
	gems_changed.emit(gems)
	health_changed.emit(health, MAX_HEALTH)


func save_progress(path: String = "user://progress.json") -> void:
	var data := {
		"earth_dragon_defeated": earth_dragon_defeated,
		"air_dragon_defeated": air_dragon_defeated,
		"water_dragon_defeated": water_dragon_defeated,
		"fire_dragon_defeated": fire_dragon_defeated
	}
	var file := FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	if file:
		var text = JSON.stringify(data)
		file.store_string(text)
		file.close()
	else:
		push_error("No se pudo abrir archivo para guardar progreso: %s" % path)


func cargar_sprite_sin_fondo(ruta_imagen: String) -> SpriteFrames:
	var img := Image.new()
	var err := img.load(ruta_imagen)
	if err != OK:
		push_error("No se pudo cargar imagen: %s" % ruta_imagen)
		return null

	img.lock()
	var bg_col := img.get_pixel(0, 0)
	var w := img.get_width()
	var h := img.get_height()
	for x in range(w):
		for y in range(h):
			var c := img.get_pixel(x, y)
			if c == bg_col:
				c.a = 0.0
				img.set_pixel(x, y, c)
	img.unlock()

	# Create an ImageTexture from the processed Image using the static constructor
	var tex := ImageTexture.create_from_image(img)

	var frames := SpriteFrames.new()
	var frame_w := w / 6
	frame_w = int(frame_w)
	frames.add_animation("default")
	for i in range(6):
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(i * frame_w, 0, frame_w, h)
		frames.add_frame("default", atlas)

	return frames
