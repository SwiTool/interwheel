extends CharacterBody2D

signal request_focus(target)
signal death()

enum STATES {
	GROUNDED,
	FLY,
	GRAB,
	WALL_SLIDE,
	DEATH,
}

@export var ground_speed := 400.0
@export var weight = 3.5
@export var jump_force = 1800
const JUMP_SIDE_ANGLE = PI / 4

var current_wheel: Node2D
var mass := 0.0
var friction := 1.0
var state
var wa := 0.0
var wet := 0.0
var in_water := false
var is_dead := false

var pastilles_eaten := 0

func reset():
	current_wheel = null
	wet = 0
	in_water = false
	is_dead = false

func _physics_process(delta):
	if mass > 0:
		velocity.y += mass * delta * get_gravity().y
	if friction > 0:
		var f = pow(friction, delta)
		velocity *= f
	if in_water:
		var fr = pow(0.75, delta) # 0.95 initially
		velocity *= fr
		wet += 0.15 * delta;
		if velocity.y > 0:
			velocity.y *= pow(0.9, delta)
	elif wet > 0:
		wet = max(0, wet - 0.02 * delta)
	if wet > 1:
		set_state(STATES.DEATH)
	

	if state == STATES.GRAB:
		var a = (current_wheel.rotation - wa) + PI / 2
		position.x = current_wheel.position.x + cos(a) * current_wheel.ray;
		position.y = current_wheel.position.y + sin(a) * current_wheel.ray;
		rotation = a
		if Input.is_action_just_pressed('jump'):
			jump(rotation)
	elif state == STATES.FLY:
		if OS.is_debug_build() && Input.is_action_just_pressed('jump'):
			velocity.y = -jump_force
		pass
	elif state == STATES.GROUNDED:
		if Input.is_action_just_pressed('jump'):
			jump(-PI / 2)
	elif state == STATES.WALL_SLIDE:
		velocity.y += 1000 * delta;
		velocity.y *= pow(0.92, delta)
		if Input.is_action_just_pressed('jump'):
			var sens = 1 if (position.x < get_viewport().get_visible_rect().size.x / 2) else -1
			jump(-PI / 2 + JUMP_SIDE_ANGLE * sens)
	elif state == STATES.DEATH:
		wet -= 0.2 * delta

	var collision_info = move_and_collide(velocity * delta, false, 0.08, true)
	if collision_info:
		if collision_info.get_collider().name == "GroundTiles":
			if state == STATES.FLY || state == STATES.WALL_SLIDE:
				set_state(STATES.GROUNDED)
		elif collision_info.get_collider().name == "WallTiles":
			if state == STATES.FLY:
				set_state(STATES.WALL_SLIDE)
			elif state == STATES.GROUNDED:
				velocity.x = -velocity.x
		else:
			print(collision_info.get_collider().name)

func _process(_delta):
	$WaterParticles.emitting = in_water
	$WaterParticles.amount_ratio = clampf(0.2 + wet, 0, 1)
	if state == STATES.GRAB:
		pass
	elif state == STATES.FLY:
		$FlyParticles.emitting = true
		var speed = velocity.length()
		rotation = atan2(velocity.y, velocity.x)
		$AnimationPlayer.play('Flying')
		$AnimationPlayer.seek(clamp(speed / 1000, 0.0, 1.0))
	elif state == STATES.WALL_SLIDE:
		$AnimationPlayer.play('Falling')
		$AnimationPlayer.seek(clamp(velocity.length() / 1000, 0.0, 1.0))

func set_state(new_state: STATES) -> void:
	match state:
		STATES.FLY:
			mass = 0
			friction = 1
			velocity = Vector2.ZERO
			$FlyParticles.emitting = false
		STATES.GRAB:
			rotation = 0
	state = new_state
	match state:
		STATES.GROUNDED:
			# Transition to grounded
			velocity = Vector2(ground_speed, 0)
			mass = 0
			$AnimationPlayer.play("Grounded")
			rotation = -PI / 2
			pass
		STATES.GRAB:
			var ba = atan2(current_wheel.position.x - position.x, current_wheel.position.y - position.y) + PI
			wa = wrapf(current_wheel.rotation + ba, 0, TAU)
			$AnimationPlayer.play("Grabbing")
			pass
		STATES.FLY:
			# Transition to flying
			mass = weight
			friction = 0.98
			pass
		STATES.WALL_SLIDE:
			rotation = 0
			$AnimationPlayer.play('Falling')
			pass
		STATES.DEATH:
			if is_dead:
				return
			# Handle death state
			$AnimationPlayer.play('Death')
			is_dead = true
			# mass = 0
			friction = 0.2
			emit_signal('death')
			pass
	if state != STATES.GRAB:
		emit_signal('request_focus', self, 0)

func jump(a):
	GameState.jump_count += 1
	velocity.x = cos(a) * jump_force
	velocity.y = sin(a) * jump_force			
	set_state(STATES.FLY)
	current_wheel = null;

func pastille_hit(pastille: PointToken):
	GameState.pastille_eaten(pastille)
