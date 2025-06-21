extends CharacterBody2D

enum STATES {
	WALL_SLIDE,
	FLY,
	GRAB,
	WATER,
	DEATH,
}

@export var current_wheel: Node2D

const GROUND_SPEED = 15
const RAY = 8
const WEIGHT = 0.5
const JUMP = 12

const JUMP_SIDE_ANGLE = PI / 4

var weight = 0
var friction = 1
var vx = 0
var vy = 0
var state
var wa
var inst

func _input(event):
	print(event.as_text())

func _physics_process(delta):
	if weight > 0:
		vy += weight * delta
	if (friction > 0):
		var f = pow(friction, delta)
		vx *= f
		vy *= f
	position.x += vx * delta
	position.y += vy * delta

func _process(delta):
	if state == STATES.GRAB:
		var a = current_wheel.rotation - wa
		position.x = current_wheel.position.x + cos(a)*current_wheel.ray;
		position.y = current_wheel.position.y + sin(a)*current_wheel.ray;
		rotation = a
		# rotation = a/0.0174
		inst = min(inst + 0.1 * delta, 1)
		
		# var body = downcast(root).bl
		# var pince = downcast(root).pince
		
		if Input.is_action_pressed('jump'):
			print("JUMP !") 
			jump(a)
		pass
	elif state == STATES.FLY:
		# Handle flying logic
		pass
	elif state == STATES.WALL_SLIDE:
		# Handle wall sliding logic
		pass
	elif state == STATES.WATER:
		# Handle water logic
		pass
	elif state == STATES.DEATH:
		# Handle death logic
		pass

func setState(new_state: STATES) -> void:
	if state != new_state:
		state = new_state
		match state:
			STATES.GRAB:
				var ba = atan2(current_wheel.position.x - position.x, current_wheel.position.y - position.y) + PI
				wa = wrapf(current_wheel.rotation - ba, -PI, PI)
				$AnimationPlayer.play("Grabbing")
				# $AnimationPlayer.play("default")
				inst = 0
				# Cs.game.focus = {y:cw.y-Cs.VIEW_WHEEL}
				# ox=x
				# oy=y
				pass
			STATES.FLY:
				# Transition to flying
				pass
			STATES.WALL_SLIDE:
				# Transition to wall sliding
				pass
			STATES.WATER:
				# Transition to water state
				pass
			STATES.DEATH:
				# Handle death state
				pass

func jump(a):
	# Cs.game.stats.$jp++
	# flRelease = false
	# flMouseRelease = false
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
