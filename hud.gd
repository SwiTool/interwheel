extends CanvasLayer

var score_displayed := 0
var score_tween: Tween
var depth_displayed := 0
var depth_tween: Tween
var completion_tween : Tween

@onready var contract_points_label = $ColorRect/MarginContainer2/HBoxContainer/ContractLabel
@onready var progress_bar = $ColorRect/MarginContainer2/HBoxContainer/TextureProgressBar
@onready var score_label = $ColorRect/MarginContainer2/Score
@onready var depth_label = $MarginContainer/TextureRect/Depth

func _ready():
	GameState.depth_changed.connect(_on_depth_changed)
	KadokadeoManager.contract_updated.connect(_on_contract_updated)

func _on_score_changed():
	if score_tween:
		score_tween.kill()

	score_tween = create_tween()
	score_tween.tween_property(self, "score_displayed", KadokadeoManager.score, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_depth_changed(depth):
	if depth_tween:
		depth_tween.kill()

	depth_tween = create_tween()
	depth_tween.tween_property(self, "depth_displayed", GameState.depth, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_contract_updated(contract_points: float, _contract_score: int, completion_percent: float) -> void:
	contract_points_label.text = str(contract_points as int)
	if (completion_percent >= 100):
		(progress_bar.texture_progress as AtlasTexture).region.position.y = 105
	_on_score_changed()
	if completion_tween:
		completion_tween.kill()

	completion_tween = create_tween()
	completion_tween.tween_property(progress_bar, "value", completion_percent, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _process(_delta):
	score_label.text = str(round(score_displayed))
	depth_label.text = str(round(depth_displayed)) + 'm'
	
