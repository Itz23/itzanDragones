extends StaticBody2D


func _ready() -> void:
	var rect := $Visual as ColorRect
	var collision := $CollisionShape2D
	var shape := collision.shape as RectangleShape2D
	if not rect or not shape:
		return

	# Cada instancia necesita su propia forma; el subrecurso del .tscn se comparte.
	shape = shape.duplicate()
	collision.shape = shape

	var rect_size := rect.size
	shape.size = rect_size
	collision.position = rect_size * 0.5
