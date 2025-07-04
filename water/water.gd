extends Node2D

@export var water_timer := 0
@export var water_speed := 30
@export var water_speed_increment := 2
var water_boost: float = 0.0

func _ready() -> void:
	# $TopArea.connect("body_entered", Callable(self, "_on_top_area_body_entered"))
	# $TopArea.connect("body_exited", Callable(self, "_on_top_area_body_exited"))
	# $BottomArea.connect("body_entered", Callable(self, "_on_bottom_area_body_entered"))
	# $BottomArea.connect("body_exited", Callable(self, "_on_bottom_area_body_exited"))
	position.y = 1500

func _physics_process(delta: float) -> void:
	water_boost += water_speed_increment * delta

func _process(delta: float) -> void:
	position.y -= (water_speed + water_boost) * delta


func _on_top_area_body_entered(body: Node2D) -> void:
	print(body.name + ' entered')
	pass # Replace with function body.


func _on_top_area_body_exited(body: Node2D) -> void:
	print(body.name + ' left')
	pass # Replace with function body.


func _on_bottom_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_bottom_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
