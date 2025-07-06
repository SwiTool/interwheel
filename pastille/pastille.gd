extends Node2D

@export var pastilles: Array[PointToken]
var pastille: PointToken
var ray = 25

func _ready() -> void:
	for p in pastilles:
		var rnd = randf()
		if rnd <= p.probability:
			pastille = p	
			
	$PastilleSprite.texture = pastille.texture
