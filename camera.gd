extends Camera2D

var current_target: Node2D
var camera_offset_target := Vector2.ZERO

func _ready():
	global_position.x = get_viewport().get_visible_rect().size.x / 2


func _process(_delta: float) -> void:
	if current_target:
		global_position = current_target.global_position + camera_offset_target
	else:
		global_position = Vector2.ZERO
