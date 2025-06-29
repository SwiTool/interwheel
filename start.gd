extends CanvasLayer

signal start_game

func _process(_delta):
	if Input.is_action_just_pressed('jump'):
		start_game.emit()
