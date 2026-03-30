extends Node2D

@onready var terrain_renderer: Node2D = $TerrainRenderer

signal terrain_loaded(width: int, height: int, cells: Array)
signal walls_updated(cells: Array)
signal cursor_moved(player_id: String, player_state: Dictionary, block_id: int, queue_position: int, rotation: int)
signal block_rotated(player_id: String, player_state: Dictionary, block_id: int, queue_position: int, rotation: int)
signal block_placed(player_id: String, player_state: Dictionary, block_id: int, queue_position: int, rotation: int)
signal place_block_failed()

func _ready() -> void:
	if GameSession.room_id == "" or GameSession.player_id == "":
		push_error("game.gd: GameSession.room_id or player_id is empty — returning to hub")
		get_tree().change_scene_to_file("res://hub/hub.tscn")
		return

	# Start router
	Network.message_received.connect(_on_message_received)

	# Get the terrain
	await get_tree().create_timer(0.05).timeout
	Network.send_message("get_terrain")
	await get_tree().create_timer(0.05).timeout
	Network.send_message("player_ready")


# ------------------------------------------------------------
# Router
# ------------------------------------------------------------
func _on_message_received(type: String, payload: Variant) -> void:
	match type:
		"terrain":
			_ws_terrain_loaded(payload)
		"game_state":
			_ws_game_state(payload)
		"walls_updated":
			_ws_walls_updated(payload)
		"cursor_moved":
			_ws_cursor_moved(payload)
		"block_rotated":
			_ws_block_rotated(payload)
		"block_placed":
			_ws_block_placed(payload)
		"place_block_failed":
			_ws_place_block_failed(payload)
		"player_position":
			_ws_player_position(payload)
		"all_player_states":
			_ws_all_player_states(payload)
		"terrain_error":
			_ws_terrain_error(payload)

# Disconnect signals when the scene is exited
func _exit_tree() -> void:
	Network.message_received.disconnect(_on_message_received)

# ------------------------------------------------------------
# WS message handlers
# ------------------------------------------------------------

func _ws_terrain_error(payload: Variant) -> void:
	print_debug("game.gd: _ws_terrain_error", payload)
	get_tree().change_scene_to_file("res://hub/hub.tscn")

func _ws_all_player_states(payload: Variant) -> void:
	print_debug("game.gd: _ws_all_player_states", payload)

	# Spawn players that are not already spawned
	for player_state_payload in payload.get("players", []):
		if GameSession.players.has(player_state_payload.get("player_id", "")) == true:
			continue

		print_debug("game.gd: spawning player", player_state_payload)
		# Spawn player node
		var player_node = preload("res://game/player.tscn").instantiate()
		var pid: String = player_state_payload.get("player_id", "")
		player_node.id = pid

		# Local if ID matches player ID
		player_node.is_local = pid == GameSession.player_id


		# Move cursor to position
		var cursor_x: int = player_state_payload.get("cursor_x", 0)
		var cursor_y: int = player_state_payload.get("cursor_y", 0)
		var block_id: int = player_state_payload.get("block_id", 0)
		var rotation_index: int = player_state_payload.get("rotation", 0)


		add_child(player_node)
		GameSession.players[pid] = player_node
		player_node.DrawBlock(block_id, rotation_index)
		player_node.MoveCursor(Vector2(cursor_x, cursor_y))


func _ws_terrain_loaded(payload: Variant) -> void:
	print_debug("game.gd: _on_terrain_loaded", payload)
	var width: int = payload.get("width", 0)
	var height: int = payload.get("height", 0)
	var rle: Array = payload.get("cells_rle", [])

	# Decode RLE → flat array → 2D array
	var flat: Array = []
	var value: int = 0
	for count in rle:
		for _i in range(count):
			flat.append(value)
		value = 1 - value

	var cells: Array = []
	for y in range(height):
		var row: Array = []
		for x in range(width):
			row.append(flat[y * width + x])
		cells.append(row)

	if flat.size() != width * height:
		push_error("game.gd: terrain size mismatch", flat.size(), width, height)
		return

	GameSession.terrain_width = width
	GameSession.terrain_height = height
	GameSession.terrain_cells = cells
	terrain_loaded.emit(width, height, cells)
	terrain_renderer.build_terrain(cells)


func _ws_game_state(payload: Variant) -> void:
	print_debug("game.gd: _ws_game_state", payload)
	var gs: String = payload.get("game_state", "")
	GameSession.game_state = gs
	#_players_to_dict(payload.get("players", {}))


func _ws_walls_updated(payload: Variant) -> void:
	print_debug("game.gd: _ws_walls_updated", payload)
	var cells: Array = payload.get("cells", [])
	GameSession.wall_cells = cells
	walls_updated.emit(cells)


func _ws_cursor_moved(payload: Variant) -> void:
	print_debug("game.gd: _ws_cursor_moved", payload)
	var pid: String = payload.get("player_id", "")
	var player_state: Dictionary = payload.get("player_state", {})
	var block_id: int = payload.get("block_id", 0)
	var queue_position: int = payload.get("queue_position", 0)
	var piece_rotation: int = payload.get("rotation", 0)
	#_update_player_state(pid, player_state)
	cursor_moved.emit(pid, player_state, block_id, queue_position, piece_rotation)


func _ws_block_rotated(payload: Variant) -> void:
	print_debug("game.gd: _ws_block_rotated", payload)
	var pid: String = payload.get("player_id", "")
	var player_state: Dictionary = payload.get("player_state", {})
	var block_id: int = payload.get("block_id", 0)
	var queue_position: int = payload.get("queue_position", 0)
	var piece_rotation: int = payload.get("rotation", 0)
	#_update_player_state(pid, player_state)
	block_rotated.emit(pid, player_state, block_id, queue_position, piece_rotation)


func _ws_block_placed(payload: Variant) -> void:
	print_debug("game.gd: _ws_block_placed", payload)
	var pid: String = payload.get("player_id", "")
	var player_state: Dictionary = payload.get("player_state", {})
	var block_id: int = payload.get("block_id", 0)
	var queue_position: int = payload.get("queue_position", 0)
	var piece_rotation: int = payload.get("rotation", 0)
	#_update_player_state(pid, player_state)
	block_placed.emit(pid, player_state, block_id, queue_position, piece_rotation)


func _ws_place_block_failed(payload: Variant) -> void:
	print_debug("game.gd: _ws_place_block_failed", payload)
	place_block_failed.emit()


func _update_player_state(pid: String, player_state: Dictionary) -> void:
	if pid == "":
		return

	if GameSession.players.has(pid):
		var merged_state: Dictionary = GameSession.players[pid]
		merged_state.merge(player_state, true)
		GameSession.players[pid] = merged_state
		return

	var new_state: Dictionary = player_state.duplicate(true)
	new_state["player_id"] = pid
	GameSession.players[pid] = new_state


func _ws_player_position(payload: Variant) -> void:
	print_debug("game.gd: _ws_player_positions", payload)
	var pid: String = payload.get("player_id", "")
	# Only update the other player's position

	var cursor_x: int = payload.get("cursor_x", 0)
	var cursor_y: int = payload.get("cursor_y", 0)
	var block_id: int = payload.get("block_id", 0)
	var rotation_index: int = payload.get("rotation", 0)
	# Get player node
	var player_node = GameSession.players.get(pid, null)
	if player_node == null:
		print_debug("game.gd: player node not found", pid)
		return

	# Draw block
	player_node.DrawBlock(block_id, rotation_index)

	# Move if the player is not the local player
	if GameSession.player_id != pid:
		player_node.MoveCursor(Vector2(cursor_x, cursor_y))


# ---------------------------
# Helper functions
# ---------------------------

func _players_to_dict(players_payload: Variant) -> void:
	if players_payload is Dictionary:
		for key in players_payload.keys():
			var entry: Variant = players_payload[key]
			if not (entry is Dictionary):
				continue
			var player: Dictionary = entry
			var pid: String = player.get("player_id", "")
			if pid == "":
				pid = str(key)
			if pid == "" or GameSession.players.has(pid):
				continue
			GameSession.players[pid] = player
		return

	if players_payload is Array:
		for player_var in players_payload:
			if not (player_var is Dictionary):
				continue
			var player: Dictionary = player_var
			var pid: String = player.get("player_id", "")
			if pid == "" or GameSession.players.has(pid):
				continue
			GameSession.players[pid] = player
