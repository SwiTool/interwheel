extends Node2D

@export var acceleration := 70.0  # force d’attraction
@export var max_speed := 3000.0
@export var pastilles: Array[PointToken]

var pastille: PointToken
var velocity = Vector2(0, 0)
var magnetized_by : Area2D = null
var ray = 25

func _ready() -> void:
	for p in pastilles:
		var rnd = randf()
		if rnd <= p.probability:
			pastille = p	
			
	$PastilleSprite.texture = pastille.texture
	
func _physics_process(delta: float) -> void:
	if magnetized_by:
		var offset = magnetized_by.global_position - global_position
		var direction = offset.normalized()
		var distance = offset.length()

		# Force proportionnelle à la distance (type "ressort")
		var force = direction * distance * acceleration * delta
		velocity += force

		# Limiter la vitesse
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed

	global_position += velocity * delta

func _on_outer_area_area_entered(area: Area2D) -> void:
	if area.name == 'MagnetArea':
		magnetized_by = area


func _on_center_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.pastilles_eaten += 1
		get_tree().root.get_child(0).game.add_score(pastille.points)
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play('default')
		$PastilleSprite.visible = false
		$BgSprite.visible = false
		magnetized_by = null
		velocity = Vector2.ZERO
		await $AnimatedSprite2D.animation_finished
		queue_free()
