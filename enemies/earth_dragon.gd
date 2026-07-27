extends EnemyBase
class_name EarthDragon

@export var boss_max_health := 8

@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	super._ready()
	max_health = boss_max_health
	health = max_health
	move_speed = 55.0
	patrol_distance = 180.0
	score_reward = 500
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health


func take_damage(amount: int = 1, is_fire: bool = false) -> void:
	var final_amount := amount * 2 if is_fire else amount
	super.take_damage(final_amount, is_fire)
	if health_bar:
		health_bar.value = health
	if health <= 0:
		GameManager.show_level_complete(GameManager.current_level_id)
