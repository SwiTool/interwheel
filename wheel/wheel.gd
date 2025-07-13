extends Area2D

signal request_focus(target)

const mine_scene = preload("res://mine/mine.tscn")

const RAY_MIN = 60
const RAY_MAX  = 250
const RAY_RANDOM = 50

const SPEED_MIN = 2
const SPEED_MAX = 10
const SPEED_RANDOM = 0.025


const MINE_SPACE = 36


@export var possible_wheels: Array[CompressedTexture2D]
var texture
var angle := 0.0
@export var speed := 1.0
@export var ray := 200.0
var wheel: MeshInstance2D

func _ready() -> void:
	if possible_wheels.size() > 0:
		texture = possible_wheels[randi() % possible_wheels.size()]
	else:
		push_error("No wheels available to set texture.")
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = ray
	wheel = spawn_wheel()
	
func set_ray(_ray: float):
	ray = _ray
	
	var sprite_size = texture.get_size()
	var scale_factor = ray * 2 / sprite_size.x

	$WheelMesh/Mesh.mesh.size = sprite_size * scale_factor

func spawn_wheel() -> MeshInstance2D:
	var sprite_size = texture.get_size()
	var scale_factor = ray * 2 / sprite_size.x
	var quad = QuadMesh.new()
	quad.size = sprite_size * scale_factor

	var mi = MeshInstance2D.new()
	mi.mesh = quad
	mi.texture = texture
	mi.name = 'Mesh'

	$WheelMesh.add_child(mi)
	return mi

func _process(_delta: float) -> void:
	$CollisionShape2D.shape.radius = ray
	pass

func _physics_process(delta):
	angle += speed * delta
	rotation = wrapf(angle, 0, TAU)
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" && body.state == body.STATES.FLY:
		emit_signal("request_focus", self, -250)
		body.current_wheel = self
		body.set_state(body.STATES.GRAB)

func addMine():
	var perim = TAU * ray
	var minesCount = $MinesList.get_child_count()

	if minesCount > 0 && perim / minesCount < MINE_SPACE * 2:
		pass
	
	var mineAngle := 0.0
	for tr1 in 20:
		var flBreak = true
		mineAngle = randf() * TAU
		for i in minesCount:
			var mine = $MinesList.get_child(i)
			var da = abs(wrapf(mine.angle, -PI, PI))
			if da * ray < MINE_SPACE:
				flBreak = false
				break;
		if tr1 >= 19:
			pass
		if flBreak:
			break;
	# instanciate new mine
	var nm = mine_scene.instantiate()
	nm.angle = mineAngle
	nm.position.x = cos(mineAngle) * ray
	nm.position.y = sin(mineAngle) * ray
	nm.rotation = mineAngle
	nm.add_to_group("mines")
	$MinesList.add_child(nm)
