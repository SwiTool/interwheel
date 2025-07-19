extends CanvasLayer

func enable():
	visible = true
	$Timer.start()

func disable():
	$Timer.stop()
	visible = false

func _on_timer_timeout() -> void:
	$PanelContainer/VBoxContainer/Control/Sprite2D.flip_h = !$PanelContainer/VBoxContainer/Control/Sprite2D.flip_h
