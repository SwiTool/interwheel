extends Node

@export var wheel_scene: PackedScene
var score

func _ready() -> void:
	score = 1000
	$Player.position = $StartPoint.position
	$Player.setState(2)
