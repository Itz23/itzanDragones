extends Camera2D


@export var target_path: NodePath
@export var vertical_offset := 0.0


func _ready() -> void:
	make_current()
	_snap_to_target()


func _process(_delta: float) -> void:
	_snap_to_target()


func _snap_to_target() -> void:
	if target_path.is_empty():
		return
	var target := get_node_or_null(target_path)
	if target:
		global_position = Vector2(target.global_position.x, 360.0 + vertical_offset)
