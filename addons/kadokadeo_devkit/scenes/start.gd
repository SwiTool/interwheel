@tool
extends CanvasLayer

signal start

@export var artwork: Texture2D

func _ready() -> void:
	set_process(false)
	$Button.pressed.connect(clicked)
	if artwork:
		$Button/ArtworkTexture.texture = artwork
	$AnimationPlayer.play("blink")

func clicked():
	start.emit()
