extends Node2D

@onready var room_list: ItemList = $Control/VBoxContainer/RoomList

func _ready() -> void:
	print("hub.gd: _ready")
	Network.message_received.connect(_on_message_received)
	Network.send_message("list_rooms")

# ------------------------------------------------------------
# Router
# ------------------------------------------------------------
func _on_message_received(type: String, payload: Variant) -> void:
	match type:
		"room_list":
			_ws_room_list(payload)
		"room_joined":
			_ws_room_joined(payload)
		"room_error":
			_ws_room_error(payload)

# Disconnect signals when the scene is exited
func _exit_tree() -> void:
	Network.message_received.disconnect(_on_message_received)

# ------------------------------------------------------------
# WS message handlers
# ------------------------------------------------------------
func _ws_room_list(payload: Variant) -> void:
	print_debug(payload)

	var rooms: Array = payload.get("rooms", [])
	print_debug("ws room_list", rooms)
	room_list.clear()
	for room in rooms:
		room_list.add_item(room.get("id", ""))

func _ws_room_joined(payload: Variant) -> void:
	var room_id: String = payload.get("room_id", "")
	var player_uuid: String = payload.get("player_uuid", "")
	GameSession.room_id = room_id
	GameSession.player_uuid = player_uuid
	print_debug("ws room_joined ", room_id, player_uuid)
	Network.send_message("player_ready")
	get_tree().change_scene_to_file("res://game/game.tscn")

func _ws_room_error(error: String) -> void:
	push_warning("room_error: " + error)

# ------------------------------------------------------------
# Button handlers
# ------------------------------------------------------------

func _on_reload_room_list_button_down() -> void:
	Network.send_message("list_rooms")

# Join room
func _on_room_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	print_debug("_on_item_clicked")
	var text = room_list.get_item_text(index)
	Network.send_message("join_room", {'room_id': text})

# Create room
func _on_create_room_button_down() -> void:
	print_debug("Create room clickedhandleListRooms()")
	Network.send_message("create_room")
