extends Camera2D

var current_target: Node2D
var camera_offset_target := Vector2.ZERO

func _ready():
	global_position.x = get_viewport().get_visible_rect().size.x / 2


func _process(delta: float) -> void:
	var point_focus = Vector2(get_viewport().get_visible_rect().size.x / 2, current_target.global_position.y) + camera_offset_target

	var direction = point_focus - global_position
	var distance = direction.length()
	# Normalisation pour direction
	if distance != 0:
		direction = direction.normalized()

	# Calcul d'une vitesse basée sur la distance (proportionnelle)
	var vitesse = distance * exp(0.005 * distance)
	var deplacement = direction * vitesse * delta

	# Mise à jour de la position caméra
	global_position += deplacement
	global_position.y = min(-700, global_position.y)
