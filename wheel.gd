extends Area2D

const RAY_MIN = 40
const RAY_MAX  = 160
const RAY_RANDOM = 50

const SPEED_MIN = 0.025
const SPEED_MAX = 0.125
const SPEED_RANDOM = 0.025


@export var possible_wheels: Array[CompressedTexture2D]
var angle := 0.0
var speed := 0.0
var ray

func _ready() -> void:
	if possible_wheels.size() > 0:
		$Sprite2D.texture = possible_wheels[randi() % possible_wheels.size()]
	else:
		push_error("No wheels available to set texture.")
	scale.x = ray * 2.0 / $Sprite2D.texture.get_width()
	scale.y = ray * 2.0 / $Sprite2D.texture.get_height()
	if randi() % 2 == 0:
		speed *= -1.0

func _process(delta: float) -> void:
	pass


func _physics_process(delta):
	angle += speed * delta
	rotation = rad_to_deg(angle)
	#move_and_slide()
	pass
