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

const JUMP_SIDE_ANGLE = 0.77

var weight = 0
var friction = 1
var state
var wa
var inst

func _process(delta):
	if state == STATES.GRAB:
		var a = current_wheel.rotation - wa
		position.x = current_wheel.position.x + cos(a)*current_wheel.ray;
		position.y = current_wheel.position.y + sin(a)*current_wheel.ray;
		rotation = a/0.0174
		inst = min(inst + 0.1 * delta, 1)
		
		# var body = downcast(root).bl
		# var pince = downcast(root).pince
		
		# if(checkPress())jump(a);
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
