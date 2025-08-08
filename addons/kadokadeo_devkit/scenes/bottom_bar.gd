extends CanvasLayer

var score_displayed := 0
var score_tween: Tween
var completion_tween : Tween

@onready var contract_points_label = $NinePatchRect/MarginContainer2/HBoxContainer/ContractLabel
@onready var progress_bar = $NinePatchRect/MarginContainer2/HBoxContainer/TextureProgressBar
@onready var score_label = $NinePatchRect/MarginContainer2/MarginContainer/ScoreLabel

func _ready():
	KadokadeoManager.contract_updated.connect(_on_contract_updated)

func _on_score_changed():
	if score_tween:
		score_tween.kill()

	score_tween = create_tween()
	score_tween.tween_property(self, "score_displayed", KadokadeoManager.score, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

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
	score_label.text = '%0*d' % [7, score_displayed]
	
