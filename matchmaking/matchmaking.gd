extends Node2D

@onready var status_label: Label = $Camera2D/Control/VBoxContainer/StatusLabel

func _ready() -> void:
	Network.message_received.connect(_on_message_received)
	Network.send_message("join_matchmaking", {"mode": GameSession.game_mode})

# Disconnect signals when the scene is exited (see lifecycle rules in CLAUDE.md)
func _exit_tree() -> void:
	Network.message_received.disconnect(_on_message_received)

# ------------------------------------------------------------
# Router
# ------------------------------------------------------------
func _on_message_received(type: String, payload: Variant) -> void:
	match type:
		"matchmaking_waiting":
			status_label.text = "Searching for opponent…"
		"match_found":
			_ws_match_found(payload)
		"matchmaking_error":
			status_label.text = "Matchmaking error: " + str(payload.get("error", ""))

# ------------------------------------------------------------
# WS message handlers
# ------------------------------------------------------------
func _ws_match_found(payload: Variant) -> void:
	GameSession.room_id = payload.get("room_id", "")
	GameSession.player_uuid = payload.get("player_uuid", "")
	print_debug("ws match_found ", GameSession.room_id, GameSession.player_uuid)
	Network.route_to_scene(payload.get("next_screen", "game"))

# ------------------------------------------------------------
# Button handlers
# ------------------------------------------------------------
func _on_cancel_pressed() -> void:
	Network.send_message("leave_matchmaking")
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
