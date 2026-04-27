extends Node

signal login_success
signal login_failed(error: String)
signal ws_connected
signal ws_disconnected
signal message_received(type: String, payload: Variant)

var token: String = ""

var _ws: WebSocketPeer = null
var _ws_state: WebSocketPeer.State = WebSocketPeer.STATE_CLOSED

var BASE_URL: String
var WS_URL: String

func _ready() -> void:
	if OS.get_name() == "Web":
		var host: String = JavaScriptBridge.eval("window.location.host")
		var protocol: String = JavaScriptBridge.eval("window.location.protocol")
		var ws_protocol := "wss" if protocol == "https:" else "ws"
		BASE_URL = protocol + "//" + host + "/api/v1"
		WS_URL = ws_protocol + "://" + host + "/api/v1/ws"
	else:
		BASE_URL = "http://localhost:8080/api/v1"
		WS_URL = "ws://localhost:8080/api/v1/ws"

func login(email: String, password: String) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_login_completed.bind(http))
	var body := JSON.stringify({"email": email, "password": password})
	var headers := ["Content-Type: application/json"]
	http.request(BASE_URL + "/login", headers, HTTPClient.METHOD_POST, body)


func send_message(type: String, payload: Variant = null) -> void:
	if _ws == null or _ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		push_warning("Network: cannot send, WebSocket not open")
		return

	var msg: Dictionary = payload.duplicate() if payload != null else {}
	msg["type"] = type

	print_debug(msg)
	_ws.send_text(JSON.stringify(msg))


func _process(_delta: float) -> void:
	if _ws == null:
		return

	_ws.poll()
	var state := _ws.get_ready_state()

	if state != _ws_state:
		if state == WebSocketPeer.STATE_OPEN:
			emit_signal("ws_connected")
		elif state == WebSocketPeer.STATE_CLOSED:
			emit_signal("ws_disconnected")
			_ws = null
		_ws_state = state

	if _ws != null and state == WebSocketPeer.STATE_OPEN:
		while _ws.get_available_packet_count() > 0:
			var raw = _ws.get_packet().get_string_from_utf8()
			var parsed = JSON.parse_string(raw)
			if parsed == null:
				push_warning("Network: received invalid JSON: " + raw)
				continue
			var msg_type: String = parsed.get("type", "")
			emit_signal("message_received", msg_type, parsed)


func _connect_ws() -> void:
	_ws = WebSocketPeer.new()
	_ws_state = WebSocketPeer.STATE_CONNECTING
	var err := _ws.connect_to_url(WS_URL + "?token=" + token)
	if err != OK:
		push_error("Network: WebSocket connect_to_url failed with error " + str(err))
		_ws = null


func _on_login_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()

	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("login_failed", "Request failed (result=%d)" % result)
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed == null:
		emit_signal("login_failed", "Invalid server response")
		return

	if response_code == 200:
		token = parsed.get("token", "")
		emit_signal("login_success")
		_connect_ws()
	else:
		var error_message: String = parsed.get("error", "Login failed (HTTP %d)" % response_code)
		emit_signal("login_failed", error_message)
