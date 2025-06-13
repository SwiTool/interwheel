extends Node

@export var wall_scene: PackedScene
var score

func game_over():
	$ScoreTimer.stop()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
func _on_score_timer_timeout():
	score += 1

func _on_start_timer_timeout():
	$ScoreTimer.start()
	
func _ready():
	new_game()
