extends Node2D


@onready var pause_menu: CanvasLayer = $PauseMenu


func _ready() -> void:
	add_to_group("level")
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.make_current()
	_connect_player_attack()


func toggle_pause() -> void:
	var tree := get_tree()
	tree.paused = not tree.paused
	pause_menu.visible = tree.paused


func _connect_player_attack() -> void:
	var player := get_node_or_null("Player") as Player
	if not player:
		return
	player.attack_area.area_entered.connect(_on_player_attack_hit.bind(player))
	player.attack_area.body_entered.connect(_on_player_attack_body.bind(player))


func _on_player_attack_hit(area: Area2D, player: Player) -> void:
	var enemy := area.get_parent()
	if enemy and enemy.is_in_group("enemies"):
		var is_fire: bool = player.attack_area.get_meta("fire_attack", false)
		enemy.take_damage(1 if not is_fire else 2, is_fire)


func _on_player_attack_body(body: Node, player: Player) -> void:
	if body.is_in_group("enemies"):
		var is_fire: bool = player.attack_area.get_meta("fire_attack", false)
		body.take_damage(1 if not is_fire else 2, is_fire)
