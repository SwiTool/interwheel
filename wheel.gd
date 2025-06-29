extends Area2D

signal request_focus(target)

const mine_scene = preload("res://mine.tscn")

const RAY_MIN = 40
const RAY_MAX  = 160
const RAY_RANDOM = 50

const SPEED_MIN = 2
const SPEED_MAX = 10
const SPEED_RANDOM = 0.025


const MINE_SPACE = 36


@export var possible_wheels: Array[CompressedTexture2D]
var texture
var angle := 0.0
var speed := 0.0
var ray

func _ready() -> void:
	if possible_wheels.size() > 0:
		texture = possible_wheels[randi() % possible_wheels.size()]
	else:
		push_error("No wheels available to set texture.")
	# scale.x = ray * 2.0 / $Sprite2D.texture.get_width()
	# scale.y = ray * 2.0 / $Sprite2D.texture.get_height()
	if randi() % 2 == 0:
		speed *= -1.0
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = ray

func _process(_delta: float) -> void:
	var zoom = get_viewport_transform().get_scale().x
	var radius_units = ray / zoom
	$CollisionShape2D.shape.radius = radius_units
	pass

func _physics_process(delta):
	angle += speed * delta
	rotation = wrapf(angle, 0, TAU)
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" && body.state == body.STATES.FLY:
		emit_signal("request_focus", self)
		body.current_wheel = self
		body.setState(body.STATES.GRAB)

func addMine():
	var perim = TAU * ray
	var minesCount = $MinesList.get_child_count()

	if minesCount > 0 && perim / minesCount < MINE_SPACE * 2:
		pass
	
	var mineAngle := 0.0
	for tr in 20:
		var flBreak = true
		mineAngle = randf() * TAU
		for i in minesCount:
			var mine = $MinesList.get_child(i)
			var da = abs(wrapf(mine.angle, -PI, PI))
			if da * ray < MINE_SPACE:
				flBreak = false
				break;
		if tr >= 19:
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
