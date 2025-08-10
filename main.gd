extends Node

const game_scene = preload("res://game.tscn")
var game: Node

@onready var start = $Start
@onready var end = $End

func _ready() -> void:
	set_process(false)
	KadokadeoManager.initialize("7")
	start.connect('start', _on_start_game)
	end.connect('play_again', _on_game_over_play_again)
	new_game()

func new_game():
	start.visible = true
	end.visible = false

func _on_start_game() -> void:
	game = game_scene.instantiate()
	game.connect('ready', Callable(self, 'game_ready'))
	game.connect('game_finished', Callable(self, '_on_game_finished'))
	$GameReceiver.add_child(game)

func game_ready():
	start.visible = false

func _on_game_finished() -> void:
	KadokadeoManager.end_game_session()
	await end.trigger_end()
	game.queue_free()

func _on_game_over_play_again() -> void:
	GameState.reset()
	new_game()
