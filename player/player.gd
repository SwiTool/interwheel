extends CharacterBody2D

signal request_focus(target)

enum STATES {
	GROUNDED,
	FLY,
	GRAB,
	WALL_SLIDE,
	DEATH,
}

const GROUND_SPEED = 250
const RAY = 40
const WEIGHT = 1200
const JUMP = 800
const JUMP_SIDE_ANGLE = PI / 4
const WALL_SIZE = 40

var current_wheel: Node2D
var weight := 0.0
var friction := 1.0
var vx := 0.0
var vy := 0.0
var state
var wa := 0.0
var inst
var is_dead := false

func _physics_process(delta):
	if is_dead:
		return
	if weight > 0:
		vy += weight * delta
	if (friction > 0):
		var f = pow(friction, delta)
		vx *= f
		vy *= f
	position.x += vx * delta * 2
	position.y += vy * delta * 2
	if position.y > 0:
		position.y = 0
	if position.x < 0:
		position.x = 0
	if position.x > get_viewport().size.x:
		position.x = get_viewport().size.x

func _process(delta):
	if state == STATES.GRAB:
		var a = (current_wheel.rotation - wa) + PI / 2
		position.x = current_wheel.position.x + cos(a) * current_wheel.ray;
		position.y = current_wheel.position.y + sin(a) * current_wheel.ray;
		rotation = a
		inst = min(inst + 0.1 * delta, 1)
		
		if Input.is_action_just_pressed('jump'):
			jump(a)
		pass
	elif state == STATES.FLY:
		# Handle flying logic
		if Input.is_action_just_pressed('jump'):
			vy = -750
			# vx = 0
		if position.x < WALL_SIZE:
			position.x = WALL_SIZE
			setState(STATES.WALL_SLIDE)
		if position.x > get_viewport().size.x - 2 * WALL_SIZE:
			position.x = get_viewport().size.x - 2 * WALL_SIZE
			setState(STATES.WALL_SLIDE)
		var speed = Vector2(vx, vy).length()
		rotation = atan2(vy, vx)
		$AnimationPlayer.play('Flying')
		$AnimationPlayer.seek(clamp(speed / 1000, 0.0, 1.0))
		pass
	elif state == STATES.GROUNDED:
		# Handle wall sliding logic
		if Input.is_action_just_pressed('jump'):
			jump(-PI / 2)
		if position.x < WALL_SIZE:
			position.x = WALL_SIZE
			vx = -vx
		if position.x > get_viewport().size.x - 2 * WALL_SIZE:
			position.x = get_viewport().size.x - 2 * WALL_SIZE
			vx = -vx
		pass
	elif state == STATES.WALL_SLIDE:
		# Handle wall slide logic
		vy += 160 * delta;
		vy *= pow(0.92, delta)
		if Input.is_action_just_pressed('jump'):
			var sens = 1 if (position.x < get_viewport().size.x / 2) else -1
			jump(-PI / 2 + JUMP_SIDE_ANGLE * sens)
		pass
		$AnimationPlayer.play('Falling')
		$AnimationPlayer.seek(clamp(Vector2(vx, vy).length() / 1000, 0.0, 1.0))
	elif state == STATES.DEATH:
		# Handle death logic
		pass

func setState(new_state: STATES) -> void:
	match state:
		STATES.FLY:
			weight = 0
			friction = 1
			vx = 0
			vy = 0
		STATES.GRAB:
			rotation = 0
	state = new_state
	match state:
		STATES.GROUNDED:
			# Transition to grounded
			vx = GROUND_SPEED if position.x < get_viewport().size.x / 2 else -GROUND_SPEED
			vy = 0
			weight = 0
			$AnimationPlayer.play("Grounded")
			rotation = -PI / 2
			pass
		STATES.GRAB:
			var ba = atan2(current_wheel.position.x - position.x, current_wheel.position.y - position.y) + PI
			wa = wrapf(current_wheel.rotation + ba, 0, TAU)
			$AnimationPlayer.play("Grabbing")
			# $AnimationPlayer.play("default")
			inst = 0
			# Cs.game.focus = {y:cw.y-Cs.VIEW_WHEEL}
			# ox=x
			# oy=y
			pass
		STATES.FLY:
			# Transition to flying
			weight = WEIGHT
			friction = 0.98
			pass
		STATES.WALL_SLIDE:
			# Transition to water state
			rotation = -PI / 2
			$AnimationPlayer.play('Falling')
			pass
		STATES.DEATH:
			if is_dead:
				return
			# Handle death state
			$AnimationPlayer.play('Death')
			is_dead = true
			vx = 0
			vy = 0
			weight = 0
			get_parent().end_game()
			pass
	if state != STATES.GRAB:
		emit_signal("request_focus", self)

func jump(a):
	# Cs.game.stats.$jp++
	# var max = 4
	# for( var i=0; i<max; i++ ){
	# 	var dec = Math.random()*2-1
	# 	var na = a + dec*0.8
	# 	var sp = 8-Math.abs(dec)*6
	# 	var c = i/max
	# 	var p = newPart();
	# 	p.vx = Math.cos(na)*sp
	# 	p.vy = Math.sin(na)*sp
	# 	p.setScale(50+c*100);
	# 	p.timer = 10+Math.random()*30
	# 	p.weight = 0.2+c*0.2
	# }

	vx = cos(a) * JUMP
	vy = sin(a) * JUMP			
	setState(STATES.FLY)
	current_wheel = null;

#func on_wall_touched() -> void:
#	if state == STATES.FLY:
#		setState(STATES.WALL_SLIDE)
#	elif state == STATES.GROUNDED:
#		vx = -vx

func on_ground_touched() -> void:
	if state == STATES.FLY || state == STATES.WALL_SLIDE:
		setState(STATES.GROUNDED)
