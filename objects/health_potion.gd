extends Area2D


func _ready() -> void:
	add_to_group("health_potion")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.collect_item(self)


func _on_area_entered(area: Area2D) -> void:
	var player := area.get_parent()
	if player and player.is_in_group("player"):
		player.collect_item(self)
