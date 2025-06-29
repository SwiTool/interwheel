extends Area2D

var angle : float

func _on_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		# body.position = position
		body.setState(body.STATES.DEATH)
