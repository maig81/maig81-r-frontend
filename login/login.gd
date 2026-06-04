extends Node2D

@onready var username_field: LineEdit = $CanvasLayer/Control/VBoxContainer/Username
@onready var password_field: LineEdit = $CanvasLayer/Control/VBoxContainer/Password
@onready var login_button: Button = $CanvasLayer/Control/VBoxContainer/Button
@onready var guest_button: Button = $CanvasLayer/Control/VBoxContainer/GuestButton


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

func _on_guest_button_pressed() -> void:
	print_debug("Guest button pressed")


func _on_login_success() -> void:
	print("Login: authenticated, waiting for WebSocket connection...")


func _on_login_failed(error: String) -> void:
	login_button.disabled = false
	print("Login failed: " + error)

func _exit_tree() -> void:
	Network.login_success.disconnect(_on_login_success)
	Network.login_failed.disconnect(_on_login_failed)
	Network.ws_connected.disconnect(_on_ws_connected)

func _on_ws_connected() -> void:
	print("Login: WebSocket connected")
	# TODO: transition to the game/lobby scene
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
