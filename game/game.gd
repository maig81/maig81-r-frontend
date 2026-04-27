extends Node2D

@onready var terrain_renderer: Node = $TerrainRenderer
@onready var wall_renderer: Node = $WallRenderer
@onready var enclosed_region_renderer: Node = $EnclosedRegionRenderer
@onready var castle_renderer: Node = $CastleRenderer

var _debug_label: Label


func _ready() -> void:
	if GameSession.room_id == "" or GameSession.player_uuid == "":
		push_error("game.gd: GameSession.room_id or player_uuid is empty — returning to hub")
		get_tree().change_scene_to_file("res://hub/hub.tscn")
		return

	Network.message_received.connect(_on_message_received)

	Network.send_message("get_game_state")

	_debug_label = Label.new()
	_debug_label.position = Vector2(10, 10)
	_debug_label.z_index = 100
	add_child(_debug_label)


func _process(_delta: float) -> void:
	if _debug_label == null:
		return
	var lines: Array = ["Status: " + str(GameSession.game_status)]
	for idx in GameSession.players:
		var node = GameSession.players[idx]
		var grid_pos = node.position / 16
		var local = "(local)" if idx == GameSession.player_index else ""
		lines.append("Player %d%s: grid(%d, %d)" % [idx, local, int(grid_pos.x), int(grid_pos.y)])
	_debug_label.text = "\n".join(lines)


# ------------------------------------------------------------
# Router
# ------------------------------------------------------------
func _on_message_received(type: String, payload: Variant) -> void:
	match type:
		"update":
			for event in payload.get("events", []):
				_handle_event(event.get("type", ""), event)


func _handle_event(type: String, payload: Variant) -> void:
	match type:
		"terrain":
			_ws_terrain(payload)
		"game_player":
			_ws_game_player(payload)
		"player_position":
			_ws_player_position(payload)
		"walls_updated":
			_ws_walls_updated(payload)
		"place_block_failed":
			_ws_place_block_failed(payload)
		"enclosed_regions":
			_ws_enclosed_regions(payload)


func _exit_tree() -> void:
	Network.message_received.disconnect(_on_message_received)


# ------------------------------------------------------------
# WS message handlers
# ------------------------------------------------------------

func _ws_terrain(_payload: Variant) -> void:
	var terrain: Dictionary = _payload.get("terrain", {})
	var width: int = terrain.get("width", 0)
	var height: int = terrain.get("height", 0)
	var rle: Array = terrain.get("cells", [])
	var cells: Array = terrain_renderer._decode_rle(width, height, rle)
	var castles: Array = terrain.get("castles", {})

	GameSession.terrain_width = width
	GameSession.terrain_height = height
	GameSession.terrain_cells = cells

	terrain_renderer.build_terrain(cells)
	castle_renderer.draw_castles(castles)


func _ws_game_player(payload: Variant) -> void:
	var player_state: Dictionary = payload.get("player", {})
	var idx: int = player_state.get("idx", -1)
	var player_uuid: String = player_state.get("uuid", "")


	if GameSession.players.has(idx):
		return

	if player_uuid == GameSession.player_uuid:
		GameSession.player_index = idx

	var player_node = preload("res://game/player.tscn").instantiate()
	player_node.index = idx
	player_node.is_local = player_uuid == GameSession.player_uuid

	var cursor_x: int = player_state.get("x", 0)
	var cursor_y: int = player_state.get("y", 0)
	var block_id: int = player_state.get("block", 0)
	var rotation_index: int = player_state.get("r", 0)

	add_child(player_node)
	GameSession.players[idx] = player_node
	player_node.DrawBlock(block_id, rotation_index)
	player_node.MoveCursor(Vector2(cursor_x, cursor_y))


func _ws_player_position(_payload: Variant) -> void:
	var pos: Dictionary = _payload.get("position", {})
	var idx: int = pos.get("index", -1)
	var x: int = pos.get("x", 0)
	var y: int = pos.get("y", 0)
	var block: int = pos.get("block", 0)
	var r: int = pos.get("r", 0)

	var player_node = GameSession.players.get(idx, null)
	if player_node == null:
		print_debug("game.gd: player node not found for index", idx)
		return

	player_node.DrawBlock(block, r)

	if GameSession.player_index != idx:
		player_node.MoveCursor(Vector2(x, y))


func _ws_walls_updated(payload: Variant) -> void:
	var cells: Array = payload.get("cells", [])
	GameSession.wall_cells = cells
	wall_renderer.draw_walls(cells)


func _ws_place_block_failed(_payload: Variant) -> void:
	print_debug("game.gd: place_block_failed")
	# TODO visual feedback for failed placement

func _ws_enclosed_regions(_payload: Variant) -> void:
	var cells: Array = _payload.get("regions", [])
	enclosed_region_renderer.draw_regions(cells)
	print_debug(cells)

	castle_renderer.set_surrounded_castles(cells)
