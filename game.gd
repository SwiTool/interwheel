extends Node

signal game_initialized

const SIDE = 60
const SPACE = 40

@export var max_wheels := 50
@export var dif_randomizer := 0.03

@export var wheel_dist_min := 400
@export var wheel_dist_max := 550

const wheel_scene = preload("res://wheel/wheel.tscn")
const pastille_scene = preload("res://pastille/pastille.tscn")
var mcw
var mch
var is_end = true

var wheels = []

func _ready() -> void:
	Engine.time_scale = 1.0
	$Player.connect("request_focus", Callable(self, "_on_request_focus"))
	mcw = get_viewport().get_visible_rect().size.x
	mch = get_viewport().get_visible_rect().size.y
	initWheels()
	initPastilles()
	for wheel in get_tree().get_nodes_in_group("wheels"):
		wheel.connect("request_focus", Callable(self, "_on_request_focus"))
	$Player.current_wheel = wheels[0]
	$Player.set_state(2)
	$Camera2D.current_target = $Player.current_wheel
	game_initialized.emit()

func _on_request_focus(target: Node2D, offset: float) -> void:
	if target != null:
		$Camera2D.current_target = target
		$Camera2D.camera_offset_target = Vector2(0, offset)

func _process(_delta):
	$HUD.set_depth(abs(int($Player.position.y / 20)))
	
func add_score(points: int):
	$HUD.add_score(points)

func end_game():
	var timer := 0.0
	var start_scale := Engine.time_scale

	while timer < 1.0:
		var t := timer / 1.0
		Engine.time_scale = lerp(start_scale, 0.0, t)
		await get_tree().process_frame
		timer += get_process_delta_time()
	Engine.time_scale = 0.0

func spawn_wheel(x: int, y: int, ray: float, speed: float) -> Node2D:
	var ow = wheel_scene.instantiate()
	ow.position = Vector2(x, y)
	ow.speed = speed
	ow.ray = ray
	ow.add_to_group("wheels")
	$Wheels.add_child(ow)
	wheels.push_back(ow)
	return ow

func initWheels() -> void:
	var owRay = (mcw - 2 * (SIDE + SPACE)) * 0.25
	var ow = spawn_wheel(mcw * 0.5, -680, owRay, 1.0)

	for i: float in max_wheels:
		var c = clampf((i / max_wheels) + randf_range(0, 1) * dif_randomizer, 0.0, 1.0)
		var c2 = clampf((i / max_wheels) + randf_range(0, 1) * dif_randomizer, 0.0, 1.0)
		var c3 = clampf((i / max_wheels) + randf_range(0, 1) * dif_randomizer, 0.0, 1.0)
		#print('wheel %d: %.2f / %.2f / %.2f' % [i + 1, c, c2, c3])

		var ray = ow.RAY_MIN + (1 - c2) * (ow.RAY_MAX - ow.RAY_MIN) + randf_range(0, ow.RAY_RANDOM)
		var speed = ow.SPEED_MIN + c3 * (ow.SPEED_MAX - ow.SPEED_MIN) + randf_range(0, ow.SPEED_RANDOM)
		var w = spawn_wheel(0, 0, ray, speed)

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

		while randf() + 0.4 < c:
			w.addMine();


		# // INTER WHEEL
		if randf() > c:
			var nw = spawn_wheel(0, 0, 0, 0)
			nw.position.y = (w.position.y + ow.position.y) * 0.5

			var ok = false
			for tr1 in 30:
				flBreak = true

				nw.set_ray(randf_range(nw.RAY_MIN + 50, nw.RAY_MAX - nw.RAY_MIN))
				nw.speed = randf_range(nw.SPEED_MIN, nw.SPEED_MAX - nw.SPEED_MIN)
				var m = SIDE + SPACE + nw.ray
				nw.position.x = m + mcw - (2 * m)
				var lst = [w,ow]
				for w2 in lst:
					if nw.position.distance_to(w2.position) < nw.ray + w2.ray + SPACE:
						flBreak = false;
						break;

				if flBreak:
					ok = true
					break;
			if !ok:
				nw.queue_free()

		ow = w
#     }
#     roof = ow.y - ow.ray
#     eList.push({list:list,s:Cs.START_WHEEL_ID,e:Cs.START_WHEEL_ID-1})
# }

func initPastilles():
	var y = -500
	while y > wheels[wheels.size() - 1].position.y:
		#print(y / wheels[wheels.size() - 1].position.y)
		if randf() < y/wheels[wheels.size() - 1].position.y:
			var p = pastille_scene.instantiate()
			var m = SIDE + p.ray
			p.position.x = randf_range(m, mcw - m)
			p.position.y = y
			$Pastilles.add_child(p)
			# list.push(p)
		y -= 100


func _on_player_death() -> void:
	end_game()
