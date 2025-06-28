extends Node

const SIDE = 60
const SPACE = 40

const WMAX = 50
const DIF_RANDOMIZER = 0.1

@export var wheel_dist_min = 400
@export var wheel_dist_max = 600

const wheel_scene = preload("res://wheel.tscn")
const wall_scene = preload("res://wall.tscn")
var mcw
var mch

var wheels = []

func _ready() -> void:
	$Player.connect("request_focus", Callable(self, "_on_request_focus"))
	mcw = get_viewport().size.x
	mch = get_viewport().size.y
	initWheels()
	initDecor()
	for wheel in get_tree().get_nodes_in_group("wheels"):
		wheel.connect("request_focus", Callable(self, "_on_request_focus"))
	$Player.current_wheel = wheels[0]
	$Player.setState(2)
	$Camera2D.current_target = $Player.current_wheel

func _on_request_focus(target: Node2D) -> void:
	if target != null:
		$Camera2D.current_target = target

func _process(delta):
	$HUD.set_depth(abs(int($Player.position.y * 0.2)))

func initWheels() -> void:
	var ow = wheel_scene.instantiate()
	ow.ray = (mcw - 2 * (SIDE+SPACE))*0.25
	ow.position.x = mcw * 0.5
	ow.position.y = -680
	ow.speed = 1
	ow.add_to_group("wheels")

	add_child(ow)
	wheels.push_back(ow)

	for i: float in WMAX:
		var c = clamp((i / WMAX) + randf_range(-1, 1) * DIF_RANDOMIZER, 0.0, 1.0)
		var c2 = clamp((i / WMAX) + randf_range(-1, 1) * DIF_RANDOMIZER, 0.0, 1.0)
		var c3 = clamp((i / WMAX) + randf_range(-1, 1) * DIF_RANDOMIZER, 0.0, 1.0)

		var w = wheel_scene.instantiate()
		w.add_to_group("wheels")
		w.ray = w.RAY_MIN + (1-c2)*(w.RAY_MAX - w.RAY_MIN) + randf_range(0, w.RAY_RANDOM)
		w.speed = w.SPEED_MIN + c3*(w.SPEED_MAX-w.SPEED_MIN) + randf_range(0, w.SPEED_RANDOM)

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
		while randf() + 0.4 < c:
			w.addMine();


		# // INTER WHEEL
		if randf() > c:
			var nw = wheel_scene.instantiate()
			nw.add_to_group("wheels")
			nw.position.y = (w.position.y + ow.position.y) * 0.5

			for tr in 30:
				flBreak = true

				nw.ray = randf_range(nw.RAY_MIN + 50, nw.RAY_MAX - nw.RAY_MIN)
				nw.speed = randf_range(nw.SPEED_MIN, nw.SPEED_MAX - nw.SPEED_MIN)
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

func initDecor():
	var wall = wall_scene.instantiate()
	var tex = wall.get_node("Sprite2D").texture
	var size = tex.get_height()
	var height = wheels[-1].position.y
	var xMax = mcw / size
	var yMax = height / size

	# 0x00436B70 # wall color
	# for x in xMax:
	#     for y in yMax:
	#         var mc = gdm.attach("mcTile",10)
	#         mc.gotoAndStop(string(n*10+Std.random(10)+1))
	#         Cs.drawMcAt(bmp,mc,x*size,y*size)
	#         mc.removeMovieClip();

	# var by = 100
	# while(by<2000){
	#     if(Math.random()<0.2){
	#         var link = "mcMotif"
	#         var bx = Std.random(mcw)
	#         if(Math.random()<0.2){
	#             link = "mcFrise"
	#             bx = mcw*0.5
	#         }
	#         var mc = gdm.attach(link,10)
	#         by += mc._height*0.5
	#         mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
	#         Cs.drawMcAt(bmp,mc,bx,by)
	#         by += mc._height*0.5
	#         mc.removeMovieClip();
	#     }

	#     by+= Std.random(100)

	# }

	#for y in 100:
	#	for x in 7:
	#		$BgTiles.set_cell(Vector2i(x, -y), 0, Vector2i(randi() % 4, randi() % 3))

	#for y in abs(yMax):
	#	for i in 2:
	#		wall = wall_scene.instantiate()
	#		wall.global_position.x = i+1 * (mcw-SIDE)
	#		wall.global_position.y = -y * size
	#		$Walls.add_child(wall)
	# var skin = dm.empty(DP_BG)
	# skin.attachBitmap(bmp,1)
	# skin._y = -(n+1)*height
