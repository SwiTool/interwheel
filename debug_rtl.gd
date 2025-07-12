extends RichTextLabel

@export var player_path : NodePath = "res://Player.tscn"
var player : Node

func _ready():
	player = get_node(player_path)
	clear()

func _process(_delta):
	if Input.is_action_just_pressed("toggle_debug"):
		visible = !visible
	if not visible or player == null:
		return
	var pos = player.position
	var info = ""
	info += "Pos: (%.1f, %.1f)\n" % [pos.x, pos.y]
	info += "Vel: (%.1f, %.1f)\n" % [player.velocity.x, player.velocity.y]
	info += "Ang: %d (%.2f rad)\n" % [rad_to_deg(player.rotation), player.rotation]
	info += "Wtr: %s\n" % player.in_water
	info += "Wet: %.5f\n" % player.wet
	text = info
