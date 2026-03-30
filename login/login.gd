extends Node2D

@onready var username_field: LineEdit = $Control/VBoxContainer/Username
@onready var password_field: LineEdit = $Control/VBoxContainer/Password
@onready var login_button: Button = $Control/VBoxContainer/Button


func _ready() -> void:
	GameSession.reset()
	login_button.pressed.connect(_on_login_pressed)
	Network.login_success.connect(_on_login_success)
	Network.login_failed.connect(_on_login_failed)
	Network.ws_connected.connect(_on_ws_connected)

func _on_login_pressed() -> void:
	var email := username_field.text.strip_edges()
	var password := password_field.text
	if email.is_empty() or password.is_empty():
		print("Login: email and password are required")
		return
	login_button.disabled = true
	Network.login(email, password)


func _on_login_success() -> void:
	print("Login: authenticated, waiting for WebSocket connection...")


func _on_login_failed(error: String) -> void:
	login_button.disabled = false
	print("Login failed: " + error)


func _on_ws_connected() -> void:
	print("Login: WebSocket connected")
	# TODO: transition to the game/lobby scene
	get_tree().change_scene_to_file("res://hub/hub.tscn")
