extends CanvasLayer

var depth_displayed := 0
var depth_tween: Tween

@onready var depth_label = $MarginContainer/TextureRect/Depth

func _ready():
	GameState.depth_changed.connect(_on_depth_changed)

func _on_depth_changed(depth):
	if depth_tween:
		depth_tween.kill()

	depth_tween = create_tween()
	depth_tween.tween_property(self, "depth_displayed", GameState.depth, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

func _process(_delta):
	depth_label.text = str(round(depth_displayed)) + 'm'
	
