extends Node2D

@export var water_timer := 0
@export var water_speed := 30.0
@export var water_speed_increment := 1.5
var water_boost: float = 0.0

func _ready() -> void:
	# $TopArea.connect("body_entered", Callable(self, "_on_top_area_body_entered"))
	# $TopArea.connect("body_exited", Callable(self, "_on_top_area_body_exited"))
	# $BottomArea.connect("body_entered", Callable(self, "_on_bottom_area_body_entered"))
	# $BottomArea.connect("body_exited", Callable(self, "_on_bottom_area_body_exited"))
	position.y = 1500
	#position.y = 100

func _physics_process(delta: float) -> void:
	water_boost += water_speed_increment * delta
	position.y -= (water_speed + water_boost) * delta
	$MeshInstance2D.mesh.size.y += (water_speed + water_boost) * delta
	$MeshInstance2D.mesh.center_offset.y = $MeshInstance2D.mesh.size.y / 2


func _on_top_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		print('Player entered top water')
		body.in_water = true


func _on_top_area_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		print('Player left top water')
		body.in_water = false


func _on_bottom_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		print('Player entered deep water')
		body.set_state(body.STATES.DEATH)


func _on_bottom_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
