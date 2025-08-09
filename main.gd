extends Node

const start_scene = preload('res://addons/kadokadeo_devkit/scenes/start.tscn')
const game_scene = preload("res://game.tscn")
var game: Node
var contract: CanvasLayer

@onready var start = $Start
@onready var gameover = $GameOver

func _ready() -> void:
	set_process(false)
	KadokadeoManager.initialize("7")
	start.connect('start', _on_start_game)
	gameover.connect('play_again', _on_game_over_play_again)
	new_game()

func new_game():
	start.visible = true

func _on_start_game() -> void:
	game = game_scene.instantiate()
	game.connect('ready', Callable(self, 'game_ready'))
	game.connect('game_initialized', Callable(self, '_on_game_initialized'))
	game.connect('game_finished', Callable(self, '_on_game_finished'))
	$GameReceiver.add_child(game)

func game_ready():
	start.visible = false

func _on_game_initialized() -> void:
	pass

func _on_game_finished() -> void:
	print('game finished')
	KadokadeoManager.end_game_session()
	$GameOver.fade_in(2.0)

func _on_game_over_play_again() -> void:
	game.queue_free()
	GameState.reset()
	new_game()
	$GameOver.fade_out(0.2)
