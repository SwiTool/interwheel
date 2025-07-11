extends CanvasLayer

var score := 0
var score_displayed := 0
var score_tween: Tween
var max_depth := 0
var depth_displayed := 0
var depth_tween: Tween

func add_score(_score: int):
	score += _score

	if score_tween:
		score_tween.kill()

	score_tween = create_tween()
	score_tween.tween_property(self, "score_displayed", score, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func set_depth(depth):
	if max_depth < depth:
		add_score((depth - max_depth) * 5)
		max_depth = depth
		if depth_tween:
			depth_tween.kill()

		depth_tween = create_tween()
		depth_tween.tween_property(self, "depth_displayed", max_depth, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _process(delta):
	$HBoxContainer/ColorRect/Score.text = str(round(score_displayed))
	$Depth.text = str(round(depth_displayed)) + 'm'
	
