class_name WheelPlacer

const MIN_SPACING = 40.0

const WALL_LAYER = 1 << 0
const WHEEL_LAYER = 1 << 1

# main_direction is the direction of the wheel (0 = right, PI/2 = down, etc.)
# angle_variation is how much the wheel can deviate from that direction (in radians)
static func place_around(context: Node2D, target: Node2D, dist: float, ray: float, main_direction: float = -PI / 2, angle_variation: float = 1.4) -> Vector2:
	for _i in 30:
		var angle = main_direction + GameState.rng.randf_range(-1, 1) * angle_variation
		var pos = target.position + (Vector2(cos(angle), sin(angle)) * dist)
		var clear = is_position_clear(context, target, pos, ray)
		if clear:
			return pos
	return Vector2.ZERO

static func place_between(context: Node2D, w1: Node2D, w2: Node2D, ray: float) -> Vector2:
	var space_state = context.get_world_2d().direct_space_state
	var pos = Vector2(w1.position.x, (w1.position.y + w2.position.y) * 0.5)
	var x = [0, 0]
	
	var q1 = PhysicsRayQueryParameters2D.create(pos, pos + Vector2(context.wheel_dist_max, 0))
	var r1 = space_state.intersect_ray(q1)
	if r1.is_empty():
		x[1] = w1.position.x + context.wheel_dist_max
	
	var q2 = PhysicsRayQueryParameters2D.create(pos, pos + Vector2(-context.wheel_dist_max, 0))
	var r2 = space_state.intersect_ray(q2)
	if r2.is_empty():
		x[0] = w1.position.x - context.wheel_dist_max
	
	for _i in 30:
		pos.x = GameState.rng.randf_range(x[0], x[1])

		if is_position_clear(context, w1, pos, ray):
			return pos

	return Vector2.ZERO

# Unused but may be useful
static func random_point_in_donut(context: Node2D, from: Node2D, wheel_ray: float, margin: float, ray: float) -> Vector2:
	var r_min = wheel_ray
	var r_max = wheel_ray + margin
	for _i in 30:
		var angle = GameState.rng.randf_range(0, TAU)
		var r = sqrt(GameState.rng.randf_range(r_min * r_min, r_max * r_max))
		if is_position_clear(context, from, Vector2(cos(angle), sin(angle)) * r, r_min):
			# Ensure the point is at least r_min away from the center
			if r >= r_min:
				return Vector2(cos(angle), sin(angle)) * r
		print('r-min: ', r_min, ' r_max: ', r_max, ' r: ', r, ' -- ', r >= r_min)
	return Vector2.ZERO

#static func random_point_in_line(context: Node2D, ray: float, pos: Vector2) -> Vector2:
#	for _i in 30:
#		var query2 = PhysicsRayQueryParameters2D.create(from.position, pos)
#		var result2 = space_state.intersect_ray(query2)
#		var collided = !result2.is_empty()
#	return Vector2.ZERO

static func is_position_clear(context: Node2D, from: Node2D, pos: Vector2, ray: float, collision_mask: int = WALL_LAYER | WHEEL_LAYER) -> bool:
	var space_state = context.get_world_2d().direct_space_state
	var shape := CircleShape2D.new()
	shape.radius = ray + MIN_SPACING

	var params := PhysicsShapeQueryParameters2D.new()
	params.collide_with_areas = true
	params.shape = shape
	params.transform = Transform2D.IDENTITY.translated(pos)
	params.collision_mask = collision_mask
	params.collide_with_bodies = true

	var result = space_state.intersect_shape(params, 1)

	var query2 = PhysicsRayQueryParameters2D.create(from.position, pos)
	var result2 = space_state.intersect_ray(query2)
	var collided = !result2.is_empty()

	if OS.is_debug_build():
		var circle = ColorRect.new()
		circle.color = Color(1, 0, 0, 0.1) if result.size() > 0 || collided else Color(0, 1, 0, 0.1)
		circle.size = Vector2(ray * 2, ray * 2)
		circle.position = pos - Vector2(ray, ray)
		context.add_child(circle)
	
	return result.size() == 0 && !collided
