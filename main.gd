extends Node

const start_scene = preload('res://start.tscn')
const game_scene = preload("res://game.tscn")
var game: Node
var start: CanvasLayer

func _ready() -> void:
	start = start_scene.instantiate()
	start.connect('start_game', Callable(self, '_on_start_game'))
	add_child(start)

func _process(_delta):
	pass

func _on_start_game() -> void:
	game = game_scene.instantiate()
	game.connect('game_initialized', Callable(self, '_on_game_initialized'))
	add_child(game)
	$Start.queue_free()

func _on_game_initialized() -> void:
	print('game initialized')
