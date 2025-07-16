extends CanvasLayer

var score_displayed := 0
var score_tween: Tween
var depth_displayed := 0
var depth_tween: Tween

func _ready():
	GameState.depth_changed.connect(_on_depth_changed)
	GameState.score_changed.connect(_on_score_changed)

func _on_score_changed(_score: int):
	if score_tween:
		score_tween.kill()

	score_tween = create_tween()
	score_tween.tween_property(self, "score_displayed", GameState.score, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_depth_changed(depth):
	if depth_tween:
		depth_tween.kill()

	depth_tween = create_tween()
	depth_tween.tween_property(self, "depth_displayed", GameState.depth, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _process(_delta):
	$HBoxContainer/ColorRect/Score.text = str(round(score_displayed))
	$Depth.text = str(round(depth_displayed)) + 'm'
	
