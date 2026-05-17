extends Node

const CELL_SIZE = GameSession.CELL_SIZE

var _projectiles: Dictionary = {}  # id -> Node2D

func spawn(id, from_arr: Array, to_arr: Array, fire_tick: int, land_tick: int) -> void:
	var from_px = Vector2(from_arr[0], from_arr[1]) * CELL_SIZE
	var to_px = Vector2(to_arr[0], to_arr[1]) * CELL_SIZE
	var duration = (land_tick - fire_tick) * 0.05  # ticks → seconds (20 TPS)
	var arc_height = from_px.distance_to(to_px) * 0.4

	var node = ColorRect.new()
	node.size = Vector2(6, 6)
	node.color = Color(1, 0.8, 0)
	node.position = from_px
	add_child(node)
	_projectiles[id] = node

	var tween = create_tween()
	tween.tween_method(
	func(t: float):
		if is_instance_valid(node):
			node.position = from_px.lerp(to_px, t) + Vector2(0, -arc_height * sin(t * PI)),
	0.0, 1.0, duration
	)

func impact(id, kind: String, cell: Vector2) -> void:
	if _projectiles.has(id):
		_projectiles[id].queue_free()
		_projectiles.erase(id)

	var effect = ColorRect.new()
	effect.size = Vector2(CELL_SIZE, CELL_SIZE)
	effect.position = cell * CELL_SIZE
	effect.color = _kind_color(kind)
	add_child(effect)

	var tween = create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 0.4)
	tween.tween_callback(effect.queue_free)

func _kind_color(kind: String) -> Color:
	match kind:
		"splash": return Color(0.2, 0.5, 1.0, 0.8)
		"wall_destroyed": return Color(0.6, 0.6, 0.6, 0.8)
		"catapult_destroyed": return Color(1.0, 0.4, 0.0, 0.8)
		"castle_hit": return Color(1.0, 0.8, 0.0, 0.8)
		"rock_spark": return Color(1.0, 1.0, 0.4, 0.8)
		_: return Color(0.8, 0.7, 0.5, 0.8)
