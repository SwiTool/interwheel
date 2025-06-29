extends Area2D

var angle : float

func _on_body_entered(body: Node2D) -> void:
	if body.name == 'Player' && !body.is_dead:
		# body.position = position
		var world_pos = global_position
		var cs = get_tree().current_scene
		get_parent().remove_child(self)
		cs.add_child(self)

		global_position = world_pos
		$AnimatedSprite2D.play("explosion")
		body.setState(body.STATES.DEATH)
