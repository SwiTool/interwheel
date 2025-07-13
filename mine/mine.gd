extends Area2D

var angle : float

func _on_body_entered(body: Node2D) -> void:
	if body.name == 'Player' && !body.is_dead:
		# body.position = position
		var world_pos = global_position
		var cs = get_tree().current_scene
		get_parent().call_deferred('remove_child', self)
		cs.call_deferred('add_child', self)

		global_position = world_pos
		explode_and_die()
		body.set_state(body.STATES.DEATH)
		body.get_node('Death/Splash').visible = true

func explode_and_die() -> void:
	$AnimatedSprite2D.play("explosion")
	await $AnimatedSprite2D.animation_finished
	call_deferred("queue_free")
