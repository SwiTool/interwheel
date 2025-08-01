extends CanvasLayer
class_name StartScene

signal start_game

var can_start := false
@onready var score_label = $Panel/VBoxContainer/Panel3/HBoxContainer/VBoxContainer/ScoreLabel
@onready var points_label = $Panel/VBoxContainer/Panel3/HBoxContainer/VBoxContainer2/HBoxContainer/PointsLabel

func _ready():
	$Panel.visible = false
	$ProgressBar.visible = false
	$ErrorLabel.visible = false
	KadokadeoManager.connect('run_starting', Callable(self, '_on_run_starting'))
	KadokadeoManager.connect('run_started', Callable(self, '_on_run_started'))
	KadokadeoManager.connect('run_error', Callable(self, '_on_run_error'))
	#var run = await KadokadeoManager.start_game_session()
	#print("Run: ", run)

func _process(_delta):
	if Input.is_action_just_pressed('jump'):
		if can_start:
			start_game.emit()
		else:
			var run = await KadokadeoManager.start_game_session()
			print("Run: ", run)

func _on_run_starting() -> void:
	can_start = false
	$Panel.visible = false
	$ProgressBar.visible = true
	$ErrorLabel.visible = false

func _on_run_started() -> void:
	can_start = true
	score_label.text = str(KadokadeoManager.run_details.contract_score)
	points_label.text = str(KadokadeoManager.run_details.contract_points)
	$Panel.visible = true
	$ProgressBar.visible = false

func _on_run_error() -> void:
	can_start = false
	$Panel.visible = false
	$ProgressBar.visible = false
	$ErrorLabel.visible = true
