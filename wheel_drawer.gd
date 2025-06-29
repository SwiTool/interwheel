extends Node2D

func _draw():
	var wheel = get_parent()
	var sprite_size = wheel.texture.get_size()
	var scale_factor = (wheel.ray * 2) / sprite_size.x

	var draw_size = sprite_size * scale_factor
	var draw_pos = -draw_size / 2.0 # center

	draw_texture_rect(wheel.texture, Rect2(draw_pos, draw_size), false)
