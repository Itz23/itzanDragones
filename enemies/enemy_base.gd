extends CharacterBody2D
class_name EnemyBase

@export var max_health := 2
@export var move_speed := 90.0
@export var patrol_distance := 120.0
@export var contact_damage := 1
@export var score_reward := 100

@onready var sprite: ColorRect = $Visual
@onready var hit_area: Area2D = $HitArea

var health := max_health
var start_x := 0.0
var direction := -1


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	start_x = global_position.x
	hit_area.body_entered.connect(_on_hit_area_body_entered)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	_patrol()
	move_and_slide()


func _patrol() -> void:
	var left_limit := start_x - patrol_distance
	var right_limit := start_x + patrol_distance
	if global_position.x <= left_limit:
		direction = 1
	elif global_position.x >= right_limit:
		direction = -1
	velocity.x = direction * move_speed
	sprite.scale.x = absf(sprite.scale.x) * direction


func take_damage(amount: int = 1, _is_fire: bool = false) -> void:
	health -= amount
	sprite.modulate = Color(1.0, 0.5, 0.5)
	if health <= 0:
		GameManager.add_score(score_reward)
		queue_free()
	else:
		await get_tree().create_timer(0.08).timeout
		sprite.modulate = Color.WHITE


func _on_hit_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var player := body as Player
		if player:
			player.take_hit(self)
