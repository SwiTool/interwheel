@tool

extends Area2D

signal request_focus(target)

const mine_scene = preload("res://mine/mine.tscn")

const MINE_SPACE = 36

@export var possible_wheels: Array[CompressedTexture2D]
var texture
var angle := 0.0
@export var speed := 1.0
@export var ray := 200.0:
	set(value):
		ray = value
		if get_node_or_null('CollisionShape2D') && $CollisionShape2D.shape:
			$CollisionShape2D.shape.radius = ray
		if texture:
			var sprite_size = texture.get_size()
			var scale_factor = ray * 2 / sprite_size.x
			$WheelMesh/Mesh.mesh.size = sprite_size * scale_factor
		queue_redraw()

var wheel: Polygon2D

func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	if possible_wheels.size() > 0:
		texture = possible_wheels[KadokadeoManager.rng.randi() % possible_wheels.size()]
	else:
		push_error("No wheels available to set texture.")
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = ray
	wheel = spawn_wheel()

func spawn_wheel() -> Polygon2D:
	var sprite_size = texture.get_size()
	var scale_factor = ray * 2 / sprite_size.x
	var p = Polygon2D.new()
	var size = sprite_size * scale_factor
	p.offset = -size / 2
	p.texture = texture
	p.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	])
	p.uv = PackedVector2Array([
		Vector2(0, 0),
		Vector2(sprite_size.x, 0),
		sprite_size,
		Vector2(0, sprite_size.y),
	])

	$WheelMesh.add_child(p)
	return p

func _process(_delta: float) -> void:
	pass

func _physics_process(delta):
	angle += speed * delta
	rotation = wrapf(angle, 0, TAU)
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" && body.state == body.STATES.FLY:
		emit_signal("request_focus", self, -150)
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
		mineAngle = KadokadeoManager.rng.randf_range(0, TAU)
		for i in minesCount:
			#var mine = $MinesList.get_child(i)
			#var da = abs(wrapf(mine.angle, -PI, PI))
			if mineAngle * ray < MINE_SPACE:
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
