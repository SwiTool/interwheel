extends Node

const SIDE = 50
const SPACE = 40

const WMAX = 50
const DIF_RANDOMIZER = 0.1

@export var wheel_dist_min = 60
@export var wheel_dist_max = 120

const wheel_scene = preload("res://wheel.tscn")
var current_target: Node2D

var score

var wheels = []

func _ready() -> void:
	score = 1000
	initWheels()
	current_target = $Player
	$Camera2D.global_position.x = get_viewport().size.x / 2
	$Player.position = $StartPoint.position
	$Player.current_wheel = wheels[0]
	$Player.setState(2)

func _process(delta):
	$Camera2D.position.y = current_target.global_position.y

func initWheels() -> void:
	wheels = [];

	var mcw = get_viewport().size.x
	var mch = get_viewport().size.y

	var ow = wheel_scene.instantiate()
	ow.ray = (mcw - 2 * (SIDE+SPACE))*0.25
	ow.position.x = mcw * 0.5
	ow.position.y = 0
	ow.rotation_speed = PI/10

	add_child(ow)
	wheels.push_back(ow)

	for i: float in WMAX:
		print("Creating wheel ", i, " of ", WMAX)
		var c = clamp((i / WMAX) + randf_range(-1, 1) * DIF_RANDOMIZER, 0.0, 1.0)
		var c2 = clamp((i / WMAX) + randf_range(-1, 1) * DIF_RANDOMIZER, 0.0, 1.0)
		var c3 = clamp((i / WMAX) + randf_range(-1, 1) * DIF_RANDOMIZER, 0.0, 1.0)

		var w = wheel_scene.instantiate()
		w.ray = w.RAY_MIN + (1-c2)*(w.RAY_MAX - w.RAY_MIN) + randf_range(0, w.RAY_RANDOM)
		w.rotation_speed = w.SPEED_MIN + c3*(w.SPEED_MAX-w.SPEED_MIN) + randf_range(0, w.SPEED_RANDOM)

		var dist = wheel_dist_min + c * (wheel_dist_max - wheel_dist_min) + (ow.ray + w.ray)
		var a = null
		var lim = SIDE + SPACE + w.ray
		var flBreak = null;
		while true:
			a = -PI/2 + randf_range(-1, 1) * 1.4
			w.position.x = ow.position.x + cos(a) * dist
			w.position.y = ow.position.y + sin(a) * dist
			flBreak = w.position.x > lim && w.position.x < mcw - lim
			if flBreak:
				if wheels.size() > 1:
					var w2 = wheels[-2]
					if w2 != null:
						if w.position.distance_to(ow.position) < w.ray + w2.ray:
							flBreak = false;
			if flBreak:
				break;

		# //w.addMine();
		# while(randf()+0.4<c){
		#     w.addMine();
		# }


		# // INTER WHEEL
		if randf() > c:
			var nw = wheel_scene.instantiate()
			nw.position.y = (w.position.y + ow.position.y) * 0.5

			for tr in 30:
				flBreak = true

				nw.ray = randf_range(nw.RAY_MIN + 10, nw.RAY_MAX - nw.RAY_MIN)
				nw.rotation_speed = randf_range(nw.SPEED_MIN, nw.SPEED_MAX - nw.SPEED_MIN)
				var m = SIDE + SPACE + nw.ray
				nw.position.x = m + mcw - (2 * m)
				var lst = [w,ow]
				for w2 in lst:
					if nw.position.distance_to(w2.position) < nw.ray + w2.ray + SPACE:
						flBreak = false;
						break;

				if flBreak:
					add_child(nw)
					wheels.push_back(nw)
					break;

		add_child(w)
		wheels.push_back(w)
		ow = w
#     }
#     roof = ow.y - ow.ray
#     eList.push({list:list,s:Cs.START_WHEEL_ID,e:Cs.START_WHEEL_ID-1})
# }
