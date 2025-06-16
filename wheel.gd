extends Area2D

@export var possible_wheels: Array[CompressedTexture2D]
@export var rotation_speed: float = PI
var ray = 125

func _ready() -> void:
	if possible_wheels.size() > 0:
		$Sprite2D.texture = possible_wheels[randi() % possible_wheels.size()]
	else:
		push_error("No wheels available to set texture.")

func _update() -> void:
	pass


func _physics_process(delta):
	rotation += rotation_speed * delta
	#move_and_slide()
	pass
