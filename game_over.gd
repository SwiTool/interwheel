extends CanvasLayer

signal play_again

var tween: Tween

func fade_in(duration := 1.0):
	$PanelContainer3/VBoxContainer/PanelContainer/VBoxContainer/Score.text = "%s pts" % format_number_with_spaces(KadokadeoManager.score)
	$PanelContainer3/VBoxContainer/PanelContainer/VBoxContainer/Depth.text = "%sm" % format_number_with_spaces(GameState.max_depth)
	$PanelContainer3/VBoxContainer/GridContainer/JumpCount.text = format_number_with_spaces(GameState.jump_count)
	$PanelContainer3/VBoxContainer/GridContainer/PlungeCount.text = format_number_with_spaces(GameState.plunge_count)
	$PanelContainer3/VBoxContainer/GridContainer/PastillesCount.text = ""
	for points in GameState.pastilles_eaten_count:
		var count = GameState.pastilles_eaten_count[points]
		if count > 0:
			$PanelContainer3/VBoxContainer/GridContainer/PastillesCount.text += "\n%sx %s pts" % [format_number_with_spaces(count), format_number_with_spaces(points)]
	$PanelContainer3.modulate.a = 0.0
	if tween:
		tween.kill()
	tween = create_tween().set_ignore_time_scale()
	tween.tween_property(Engine, "time_scale", 0, 2)
	visible = true
	tween.parallel().tween_property($PanelContainer3, "modulate:a", 1.0, duration).set_delay(1)


func fade_out(duration := 1.0):
	$PanelContainer3.modulate.a = 1.0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ignore_time_scale()
	tween.tween_property(Engine, "time_scale", 1.0, 0.3)
	tween.parallel().tween_property($PanelContainer3, "modulate:a", 0.0, duration)
	await tween.finished
	visible = false


func _on_play_again_pressed() -> void:
	emit_signal('play_again')

func format_number_with_spaces(n: int) -> String:
	var str_num := str(n)
	var out := ""
	while str_num.length() > 3:
		out = " " + str_num.substr(str_num.length() - 3, 3) + out  # espace fine insécable U+202F
		str_num = str_num.substr(0, str_num.length() - 3)
	out = str_num + out
	return out
