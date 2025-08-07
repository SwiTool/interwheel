extends CanvasLayer
class_name StartScene

signal start_game

var can_start := false
@onready var score_label = $PanelContainer/Panel/VBoxContainer/Panel3/HBoxContainer/VBoxContainer/ScoreLabel
@onready var points_label = $PanelContainer/Panel/VBoxContainer/Panel3/HBoxContainer/VBoxContainer2/HBoxContainer/PointsLabel

func _ready():
	$PanelContainer.visible = false
	$ProgressBar.visible = false
	$ErrorLabel.visible = false
	KadokadeoManager.connect('run_starting', Callable(self, '_on_run_starting'))
	KadokadeoManager.connect('run_started', Callable(self, '_on_run_started'))
	KadokadeoManager.connect('run_error', Callable(self, '_on_run_error'))
	KadokadeoManager.start_game_session()

func _process(_delta):
	if Input.is_action_just_pressed('jump'):
		if can_start:
			start_game.emit()

func _on_run_starting() -> void:
	can_start = false
	$PanelContainer.visible = false
	$ProgressBar.visible = true
	$ErrorLabel.visible = false

func _on_run_started() -> void:
	can_start = true
	score_label.text = str(KadokadeoManager.run_details.contract_score)
	points_label.text = str(KadokadeoManager.run_details.contract_points)
	$PanelContainer.visible = true
	$ProgressBar.visible = false

func _on_run_error() -> void:
	can_start = false
	$PanelContainer.visible = false
	$ProgressBar.visible = false
	$ErrorLabel.visible = true
