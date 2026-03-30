extends Node2D

const CELL_SIZE = 16

func build_terrain(cells: Array) -> void:
	_clear_islands()
	var islands: Array = _find_islands(cells)
	for idx in islands.size():
		var raw: PackedVector2Array = _trace_boundary(islands[idx], cells)
		if raw.size() < 3:
			continue
		var expanded: PackedVector2Array = _expand_polygon(raw, float(CELL_SIZE))
		var smoothed: PackedVector2Array = _smooth_polygon(Array(expanded), 3)
		_spawn_line(smoothed, idx)


func _cells(cells:Array, x:int, y:int) -> int:
	var sizeY = cells.size()
	var sizeX = cells[0].size()
	if (x<0 || x>=sizeX || y<0 || y>=sizeY):
		return 0

	return cells[y][x]


func _trace_boundary(island: Dictionary, cells: Array) -> PackedVector2Array:
	var sizeY: int = cells.size()
	var sizeX: int = cells[0].size()
	var W1: int = sizeX + 1  # vertex grid width (corners, not cells)
	var edge_map: Dictionary = {}

	for encoded_idx in island:
		var cy: int = encoded_idx / sizeX
		var cx: int = encoded_idx % sizeX

		# Top neighbor — boundary edge goes left→right along top of cell
		var top_in: bool = cy > 0 and island.has((cy - 1) * sizeX + cx)
		if not top_in:
			edge_map[cy * W1 + cx] = cy * W1 + cx + 1

		# Right neighbor — boundary edge goes top→bottom along right of cell
		var right_in: bool = cx + 1 < sizeX and island.has(cy * sizeX + cx + 1)
		if not right_in:
			edge_map[cy * W1 + cx + 1] = (cy + 1) * W1 + cx + 1

		# Bottom neighbor — boundary edge goes right→left along bottom of cell
		var bot_in: bool = cy + 1 < sizeY and island.has((cy + 1) * sizeX + cx)
		if not bot_in:
			edge_map[(cy + 1) * W1 + cx + 1] = (cy + 1) * W1 + cx

		# Left neighbor — boundary edge goes bottom→top along left of cell
		var left_in: bool = cx > 0 and island.has(cy * sizeX + cx - 1)
		if not left_in:
			edge_map[(cy + 1) * W1 + cx] = cy * W1 + cx

	if edge_map.is_empty():
		return PackedVector2Array()

	var result: PackedVector2Array = PackedVector2Array()
	var start_key: int = edge_map.keys()[0]
	var current: int = start_key

	for _i in edge_map.size() + 1:
		result.append(Vector2(
			float(current % W1 * CELL_SIZE),
			float(current / W1 * CELL_SIZE)
		))
		var next_key: int = edge_map[current]
		edge_map.erase(current)
		current = next_key
		if current == start_key:
			break
	return result


# Expand the island to craete a shore
func _expand_polygon(polygon:PackedVector2Array, ammount:float)->PackedVector2Array :
	var result: Array= Geometry2D.offset_polygon(polygon, ammount)
	if (result.is_empty()):
		return polygon
	return result[0]


func _find_islands(cells: Array) -> Array:
	var sizeY: int = cells.size()
	var sizeX: int = cells[0].size()
	var visited: Array = []
	visited.resize(sizeX * sizeY)
	visited.fill(false)

	var islands: Array = []

	for y in sizeY:
		for x in sizeX:
			var idx: int = y * sizeX + x
			if visited[idx] or _cells(cells, x, y) != 1:
				visited[idx] = true
				continue

			var island: Dictionary = {}
			var queue: Array = [[x, y]]
			visited[idx] = true

			while queue.size() > 0:
				var pos = queue.pop_front()
				var cx: int = pos[0]
				var cy: int = pos[1]
				island[cy * sizeX + cx] = true

				for delta in [[1, 0], [-1, 0], [0, 1], [0, -1]]:
					var nx: int = cx + delta[0]
					var ny: int = cy + delta[1]
					if nx < 0 or nx >= sizeX or ny < 0 or ny >= sizeY:
						continue
					var nidx: int = ny * sizeX + nx
					if visited[nidx] or _cells(cells, nx, ny) != 1:
						continue
					visited[nidx] = true
					queue.append([nx, ny])

			islands.append(island)

	return islands


func _smooth_polygon(points: Array, iterations: int) -> PackedVector2Array:
	var result = points
	for _i in range(iterations):
		result = _chaikin_pass(result)
	return result

func _chaikin_pass(points: Array) -> PackedVector2Array:
	var output = []
	for i in range(len(points)):
		var p0 = points[i]
		var p1 = points[(i + 1) % len(points)]
		output.append(p0.lerp(p1, 0.25))
		output.append(p0.lerp(p1, 0.75))
	return output


func _spawn_line(polygon: PackedVector2Array, idx: int) -> void:
	# TODO Fix the layout of
	# Fill
	var fill := Polygon2D.new()
	fill.polygon = polygon
	fill.color = Color("e4e4d7")
	fill.name = "IslandFill_%d" % idx
	add_child(fill)
	fill.add_to_group("islands")

	#line
	var line = Line2D.new()
	line.closed = true
	line.points = polygon
	line.width = 5
	line.default_color = Color("434041")
	line.antialiased = true
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.name = "Island_%d" % idx

	var secondLinePolygon := _expand_polygon(polygon, 20)
	var secondLine = line.duplicate()
	secondLine.points = secondLinePolygon
	secondLine.width = 2
	secondLine.default_color = Color("45424367")

	var curve = Curve.new()
	curve.add_point(Vector2(0, 4.0))
	curve.add_point(Vector2(1.0, 3.0))
	curve.add_point(Vector2(10, 0.5))
	line.width_curve = curve

	var curve2 = Curve.new()
	curve2.add_point(Vector2(0, 0))
	curve2.add_point(Vector2(1.0, 3.0))
	curve2.add_point(Vector2(10, 0.5))
	curve2.add_point(Vector2(0, 0))
	curve2.add_point(Vector2(1.0, 3.0))
	curve2.add_point(Vector2(10, 0.5))
	curve2.add_point(Vector2(0, 0))
	curve2.add_point(Vector2(1.0, 3.0))
	curve2.add_point(Vector2(10, 0.5))
	secondLine.width_curve = curve

	add_child(line)
	add_child(secondLine)
	line.add_to_group("islands")


func _clear_islands()->void:
	for line in get_tree().get_nodes_in_group("islands"):
		line.queue_free()
