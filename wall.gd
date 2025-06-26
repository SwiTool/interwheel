extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.position.x < $Sprite2D.texture.get_width():
			body.position.x = $Sprite2D.texture.get_width() - 50
		if body.position.x > get_viewport().size.x - $Sprite2D.texture.get_width():
			body.position.x = get_viewport().size.x - $Sprite2D.texture.get_width()
		body.on_wall_touched()
