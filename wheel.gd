extends Area2D

const RAY_MIN = 20
const RAY_MAX  = 80
const RAY_RANDOM = 50

const SPEED_MIN = PI/4
const SPEED_MAX = PI
const SPEED_RANDOM = 0.05


@export var possible_wheels: Array[CompressedTexture2D]
var rotation_speed
var ray

func _ready() -> void:
	if possible_wheels.size() > 0:
		$Sprite2D.texture = possible_wheels[randi() % possible_wheels.size()]
	else:
		push_error("No wheels available to set texture.")
	scale.x = ray * 2.0 / $Sprite2D.texture.get_width()
	scale.y = ray * 2.0 / $Sprite2D.texture.get_height()


func _update() -> void:
	pass


func _physics_process(delta):
	rotation += rotation_speed * delta
	#move_and_slide()
	pass
