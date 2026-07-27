extends EnemyBase
class_name ElementalDragon

@export var dragon_element := "air"
@export var boss_max_health := 6

@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	super._ready()
	max_health = boss_max_health
	health = max_health
	move_speed = 60.0
	patrol_distance = 140.0
	score_reward = 400
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	match dragon_element:
		"air":
			$Visual.color = Color(0.67, 0.85, 0.9)
		"water":
			$Visual.color = Color(0.17, 0.42, 0.71)
		"fire":
			$Visual.color = Color(0.85, 0.33, 0.21)


func take_damage(amount: int = 1, is_fire: bool = false) -> void:
	var final_amount := amount * 2 if is_fire else amount
	super.take_damage(final_amount, is_fire)
	if health_bar:
		health_bar.value = health
	if health <= 0:
		GameManager.show_level_complete(GameManager.current_level_id)
