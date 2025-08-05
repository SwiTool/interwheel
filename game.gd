extends Node2D
class_name Game

signal game_initialized
signal game_finished

const SIDE = 80
const SPACE = 40

@export_group("Game Settings")
@export var max_wheels := 50
@export var start_wheel_position := Vector2(750, -680)
@export var start_wheel_ray := 312
@export var start_wheel_speed := 1.2
@export var dif_randomizer := 0.03

@export_group("Wheel Settings")
@export_range(100, 1000, 25) var wheel_dist_min := 400
@export_range(100, 1000, 25) var wheel_dist_max := 550
@export var wheel_ray_min = 60
@export var wheel_ray_max  = 250
@export var wheel_ray_random = 50
@export_range(1, TAU, 0.1, 'radians_as_degrees') var wheel_speed_min = 2
@export_range(1, TAU, 0.1, 'radians_as_degrees') var wheel_speed_max = 10
@export_range(0, 1, 0.005) var wheel_speed_random = 0.025

const wheel_scene = preload("res://wheel/wheel.tscn")
const pastille_scene = preload("res://pastille/pastille.tscn")
var is_end = true

var wheels = []

func _ready() -> void:
	$Player.connect("request_focus", Callable(self, "_on_request_focus"))
	$WallTiles.update_internals()
	
func remove_child_nodes(node: Node2D):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free() 

func new_game():
	$LoadingScreen.enable()
	await get_tree().process_frame
	wheels = []
	$Player.reset()
	$Water.reset()
	remove_child_nodes($Pastilles)
	remove_child_nodes($Wheels)
	Engine.time_scale = 1.0
	initWheels()
	initPastilles()
	for wheel in get_tree().get_nodes_in_group("wheels"):
		wheel.connect("request_focus", Callable(self, "_on_request_focus"))
	$Player.current_wheel = wheels[0]
	$Player.set_state(2)
	$Camera2D.current_target = $Player.current_wheel
	game_initialized.emit()
	$LoadingScreen.disable()

func _on_request_focus(target: Node2D, offset: float) -> void:
	if target != null:
		$Camera2D.current_target = target
		$Camera2D.camera_offset_target = Vector2(0, offset)

func _process(_delta):
	GameState.set_depth(abs(int($Player.position.y / 20)))

func end_game():
	game_finished.emit()
	$GameOver.fade_in(2.0)

func spawn_wheel(pos: Vector2, ray: float, speed: float) -> Node2D:
	var ow = wheel_scene.instantiate()
	ow.position = pos
	ow.speed = speed
	ow.ray = ray
	ow.add_to_group("wheels")
	$Wheels.add_child(ow)
	wheels.push_back(ow)
	return ow

func initWheels() -> void:
	var ow = spawn_wheel(start_wheel_position, start_wheel_ray, start_wheel_speed)

	for i: float in max_wheels:
		#print('wheel ', i)
		var c = clampf((i / max_wheels) + GameState.rng.randf_range(0, 1) * dif_randomizer, 0.0, 1.0)
		var c2 = clampf((i / max_wheels) + GameState.rng.randf_range(0, 1) * dif_randomizer, 0.0, 1.0)
		var c3 = clampf((i / max_wheels) + GameState.rng.randf_range(0, 1) * dif_randomizer, 0.0, 1.0)
		#print('wheel %d: %.2f / %.2f / %.2f' % [i + 1, c, c2, c3])

		var ray = wheel_ray_min + (1 - c2) * (wheel_ray_max - wheel_ray_min) + GameState.rng.randf_range(0, wheel_ray_random)
		var speed = wheel_speed_min + c3 * (wheel_speed_max - wheel_speed_min) + GameState.rng.randf_range(0, wheel_speed_random)
		var dist = wheel_dist_min + c * (wheel_dist_max - wheel_dist_min) + (ow.ray + ray)
		var p = WheelPlacer.place_around(self, ow, dist, ray)
		if p == Vector2.ZERO:
			print("No valid position found for wheel, stopping wheel generation.")
			break
		var w = spawn_wheel(p, ray, speed)

		while GameState.rng.randf() + 0.4 < c:
			w.addMine();

		# // INTER WHEEL
		if GameState.rng.randf() > c:
			var i_ray = GameState.rng.randf_range(wheel_ray_min + 50, wheel_ray_max - wheel_ray_min)
			var i_speed = GameState.rng.randf_range(wheel_speed_min, wheel_speed_max - wheel_speed_min)
			var i_pos = WheelPlacer.place_between(self, ow, w, i_ray)
			if i_pos != Vector2.ZERO:
				spawn_wheel(i_pos, i_ray, i_speed)

		ow = w

func initPastilles():
	var y = -500
	while y > wheels[wheels.size() - 1].position.y:
		
		var circle = ColorRect.new()
		circle.color = Color(1, 0, 1, 0.5)
		circle.size = Vector2(25, 25)
		circle.position = Vector2(747.5, y)
		add_child(circle)
		
		#print(y / wheels[wheels.size() - 1].position.y)
		if GameState.rng.randf() < y/wheels[wheels.size() - 1].position.y:
			var p = pastille_scene.instantiate()
			var m = SIDE + p.ray
			p.position.x = GameState.rng.randf_range(m, 1500 - m)
			p.position.y = y
			$Pastilles.add_child(p)
			# list.push(p)
		y -= 100


func _on_player_death() -> void:
	end_game()

func _on_camera_bounds_body_entered(_body: Node2D) -> void:
	var shape := $CameraBounds/CollisionShape2D.shape as RectangleShape2D
	var shape_size := shape.size
	var shape_pos = $CameraBounds/CollisionShape2D.global_position

	var half_size := shape_size * 0.5

	$Camera2D.limit_left = int(shape_pos.x - half_size.x)
	$Camera2D.limit_right = int(shape_pos.x + half_size.x)
	$Camera2D.limit_top = int(shape_pos.y - half_size.y)
	$Camera2D.limit_bottom = int(shape_pos.y + half_size.y)


func _on_game_over_play_again() -> void:
	$GameOver.fade_out(0.2)
	new_game()
