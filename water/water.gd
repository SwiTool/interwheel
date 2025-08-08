extends Node2D

@export var water_timer := 0
@export var water_speed := 30
@export var water_speed_increment := 0.0009
@export var start_position := 900.0
var water_boost: float = 0.0

func _ready() -> void:
	reset()
	
func reset():
	position.y = start_position
	water_boost = 0.0

func _physics_process(delta: float) -> void:
	water_boost += water_speed_increment * delta
	position.y -= (water_speed + water_boost) * delta
	$MeshInstance2D.mesh.size.y += (water_speed + water_boost) * delta
	$MeshInstance2D.mesh.center_offset.y = $MeshInstance2D.mesh.size.y / 2


func _on_top_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.in_water = true
		GameState.plunge_count += 1


func _on_top_area_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		body.in_water = false


func _on_bottom_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		print('Player entered deep water')
		body.set_state(body.STATES.DEATH)
