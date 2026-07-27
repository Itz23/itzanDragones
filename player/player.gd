extends CharacterBody2D
class_name Player

@export var speed := 260.0
@export var jump_velocity := -480.0
@export var dash_speed := 520.0
@export var dash_duration := 0.18
@export var attack_cooldown := 0.45
@export var invulnerability_time := 1.2

@onready var sprite: ColorRect = $Visual
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var crouch_shape: CollisionShape2D = $CollisionShape2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_remaining := 1
var is_attacking := false
var is_dashing := false
var is_crouching := false
var is_invulnerable := false
var facing := 1
var dash_timer := 0.0
var attack_timer := 0.0
var last_move_press_time := {"left": -999.0, "right": -999.0}
const DOUBLE_TAP_THRESHOLD := 0.28


func _ready() -> void:
	add_to_group("player")
	attack_area.monitoring = false
	attack_shape.disabled = true
	GameManager.health_changed.emit(GameManager.health, GameManager.MAX_HEALTH)


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	if is_dashing:
		_process_dash(delta)
	else:
		_process_movement(delta)
	_update_attack_area()
	move_and_slide()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().call_group("level", "toggle_pause")


func _update_timers(delta: float) -> void:
	if dash_timer > 0.0:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	if attack_timer > 0.0:
		attack_timer -= delta
		if attack_timer <= 0.0:
			is_attacking = false
			attack_area.monitoring = false
			attack_shape.disabled = true


func _get_move_direction() -> float:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		return direction
	if Input.is_key_pressed(KEY_LEFT):
		return -1.0
	if Input.is_key_pressed(KEY_RIGHT):
		return 1.0
	return 0.0


func _is_jump_pressed() -> bool:
	return Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_up")


func _process_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_remaining = 2 if GameManager.has_double_jump else 1

	is_crouching = is_on_floor() and (
		Input.is_action_pressed("crouch")
		or Input.is_key_pressed(KEY_DOWN)
	)
	_set_crouch_state(is_crouching)

	if is_crouching:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 10.0)
		return

	var direction := _get_move_direction()
	if direction != 0:
		facing = int(sign(direction))
		sprite.scale.x = absf(sprite.scale.x) * facing

	if GameManager.has_dash:
		_check_dash_input(direction)

	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 10.0 * delta)

	if _is_jump_pressed() and jumps_remaining > 0:
		velocity.y = jump_velocity
		jumps_remaining -= 1

	if Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
		_start_attack(false)
	elif GameManager.has_fire_sword and Input.is_action_just_pressed("fire_sword") and attack_timer <= 0.0:
		_start_attack(true)


func _check_dash_input(direction: float) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if Input.is_action_just_pressed("move_left"):
		if now - last_move_press_time["left"] <= DOUBLE_TAP_THRESHOLD and direction < 0:
			_start_dash(-1)
		last_move_press_time["left"] = now
	if Input.is_action_just_pressed("move_right"):
		if now - last_move_press_time["right"] <= DOUBLE_TAP_THRESHOLD and direction > 0:
			_start_dash(1)
		last_move_press_time["right"] = now


func _start_dash(direction: int) -> void:
	is_dashing = true
	dash_timer = dash_duration
	facing = direction
	velocity = Vector2(direction * dash_speed, 0.0)
	sprite.modulate = Color(0.6, 0.85, 1.0)


func _process_dash(_delta: float) -> void:
	velocity.y = 0.0
	sprite.modulate = Color(0.6, 0.85, 1.0) if is_dashing else Color.WHITE


func _start_attack(is_fire: bool) -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	attack_area.monitoring = true
	attack_shape.disabled = false
	sprite.modulate = Color(1.0, 0.55, 0.2) if is_fire else Color(1.0, 0.95, 0.7)
	attack_area.set_meta("fire_attack", is_fire)


func _update_attack_area() -> void:
	attack_area.position.x = 42.0 * facing
	if not is_attacking:
		sprite.modulate = Color.WHITE


func _set_crouch_state(enabled: bool) -> void:
	var shape := crouch_shape.shape as RectangleShape2D
	if enabled:
		shape.size = Vector2(28, 24)
		crouch_shape.position = Vector2(0, 12)
		sprite.size = Vector2(28, 24)
		sprite.position = Vector2(-14, -12)
	else:
		shape.size = Vector2(28, 44)
		crouch_shape.position = Vector2(0, -2)
		sprite.size = Vector2(28, 44)
		sprite.position = Vector2(-14, -22)


func take_hit(source: Node2D = null) -> void:
	if is_invulnerable or is_dashing:
		return
	if GameManager.has_stone_shield and Input.is_action_pressed("stone_shield"):
		return
	is_invulnerable = true
	GameManager.take_damage()
	sprite.modulate = Color(1.0, 0.35, 0.35)
	var knockback_x := 180.0
	if source:
		knockback_x *= sign(global_position.x - source.global_position.x)
	velocity = Vector2(knockback_x, -220.0)
	await get_tree().create_timer(invulnerability_time).timeout
	is_invulnerable = false
	sprite.modulate = Color.WHITE


func collect_item(item: Node) -> void:
	if item.is_in_group("gem"):
		GameManager.add_gem()
	elif item.is_in_group("health_potion"):
		GameManager.heal(35)
	item.queue_free()


func _on_collect_area_area_entered(area: Area2D) -> void:
	collect_item(area)
