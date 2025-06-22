extends Area2D

signal request_focus(target)

const RAY_MIN = 40
const RAY_MAX  = 160
const RAY_RANDOM = 50

const SPEED_MIN = 1
const SPEED_MAX = 5
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
	#rotation = rad_to_deg(angle)
	rotation = wrapf(angle, 0, TAU)
	#move_and_slide()
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" && body.state == body.STATES.FLY:
		emit_signal("request_focus", self)
		body.current_wheel = self
		body.setState(body.STATES.GRAB)
