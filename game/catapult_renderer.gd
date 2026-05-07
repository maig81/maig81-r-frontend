extends Node

const SIZE = 16
const Catapult = preload("res://game/terrain/catapult.tscn")

var _nodes: Dictionary = {}

func draw_catapults(catapults: Array = []) -> void:
	print_debug(catapults)
	for catapult in catapults:
		var x: int = catapult[0]
		var y: int = catapult[1]
		var key: String = "%d,%d" % [x, y]
		if _nodes.has(key):
			continue
		var catapult_node = Catapult.instantiate()
		catapult_node.position = Vector2(x, y) * GameSession.CELL_SIZE
		add_child(catapult_node)
		_nodes[key] = catapult_node

func clear() -> void:
	for node in _nodes.values():
		node.queue_free()
	_nodes.clear()
