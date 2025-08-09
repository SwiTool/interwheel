extends Area2D
class_name Pastille

@export var acceleration := 42.0  # force d’attraction
@export var max_speed := 1200.0
@export var pastilles: Array[PointToken]

var pastille: PointToken
var velocity = Vector2.ZERO
var magnetized_by : Area2D = null
static var ray = 15

func _ready() -> void:
	for p in pastilles:
		var rnd = KadokadeoManager.rng.randf()
		if rnd <= p.probability:
			pastille = p	
			
	$PastilleSprite.texture = pastille.texture
	
func _physics_process(delta: float) -> void:
	if magnetized_by:
		var offset = magnetized_by.global_position - global_position
		var direction = offset.normalized()
		var distance = offset.length()

		# Force proportionnelle à la distance (type "ressort")
		var force = direction * distance * acceleration * delta + direction * distance * 0.4
		velocity += force

		# Limiter la vitesse
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed

	global_position += velocity * delta

func _on_outer_area_area_entered(area: Area2D) -> void:
	if area.name == 'MagnetArea':
		magnetized_by = area
		$GPUParticles2D.emitting = true

func destroy():
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play('default')
	$PastilleSprite.visible = false
	$BgSprite.visible = false
	magnetized_by = null
	velocity = Vector2.ZERO
	await $AnimatedSprite2D.animation_finished
	queue_free()


func _on_center_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.pastille_hit(pastille)
		destroy()
