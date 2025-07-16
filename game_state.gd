extends Node

signal score_changed(new_score: int)
signal depth_changed(new_depth: int)
#signal pastille_eaten(points: int)

var score: int = 0
var depth: int = 0
var max_depth: int = 0
var jump_count: int = 0
var pastilles_eaten_count: Dictionary = {}
var plunge_count: int = 0

func reset():
	score = 0
	depth = 0
	jump_count = 0
	pastilles_eaten_count = {}
	plunge_count = 0
	max_depth = 0

func set_depth(depth: int):
	if (depth > max_depth):
		max_depth = depth
		var dif = depth - self.depth
		self.depth = depth
		emit_signal("depth_changed", depth)
		add_score(dif * 5)

func add_score(value: int):
	score += value
	emit_signal("score_changed", score)

func pastille_eaten(pastille: PointToken):
	if not pastilles_eaten_count.has(pastille.points):
		pastilles_eaten_count[pastille.points] = 0
	pastilles_eaten_count[pastille.points] += 1
	add_score(pastille.points)
	#emit_signal("pastille_eaten", pastille.points)
