extends Node2D

var _prev_phase: String = ""
var _tween: Tween

@export var line_color: Color = Color(0.0, 0.0, 0.0, 0.5):
	set(v):
		line_color = v
		queue_redraw()

@export var base_line_width: float = 1.0:
	set(v):
		base_line_width = v
		if _camera:
			_current_line_width = v / _camera.zoom.x
		queue_redraw()

@export var uv_scale: float = 0.004:
	set(v):
		uv_scale = v
		queue_redraw()

@export var smoothstep_lo: float = 0.2:
	set(v):
		smoothstep_lo = v
		if _mat:
			_mat.set_shader_parameter("smoothstep_lo", v)

@export var smoothstep_hi: float = 0.9:
	set(v):
		smoothstep_hi = v
		if _mat:
			_mat.set_shader_parameter("smoothstep_hi", v)

@export var alpha_min: float = 0.4:
	set(v):
		alpha_min = v
		if _mat:
			_mat.set_shader_parameter("alpha_min", v)

@onready var _camera: Camera2D = get_viewport().get_camera_2d()

var _last_zoom: float = 1.0
var _current_line_width: float = 1.0
var _noise_tex: NoiseTexture2D
var _mat: ShaderMaterial


func _ready() -> void:
	visible = true
	_last_zoom = _camera.zoom.x
	_current_line_width = base_line_width / _last_zoom

	_noise_tex = load("res://game/terrain/pencil_line_noise.tres")
	_noise_tex.changed.connect(queue_redraw)

	var shader: Shader = load("res://game/terrain/pencil_line.gdshader")
	_mat = ShaderMaterial.new()
	_mat.shader = shader
	_mat.set_shader_parameter("noise_texture", _noise_tex)
	_mat.set_shader_parameter("smoothstep_lo", smoothstep_lo)
	_mat.set_shader_parameter("smoothstep_hi", smoothstep_hi)
	_mat.set_shader_parameter("alpha_min", alpha_min)
	material = _mat


func _process(_delta: float) -> void:
	_check_phase_change()

	var zoom := _camera.zoom.x
	if zoom == _last_zoom:
		return
	_last_zoom = zoom
	_current_line_width = base_line_width / zoom
	queue_redraw()


func _draw() -> void:
	var cell := GameSession.CELL_SIZE
	var w := GameSession.terrain_width * cell
	var h := GameSession.terrain_height * cell

	if w == 0 or h == 0:
		return

	var half_w := _current_line_width * 0.5

	for ix in range(GameSession.terrain_width + 1):
		var x := float(ix * cell)
		_draw_quad(Vector2(x, 0.0), Vector2(x, float(h)), Vector2(1.0, 0.0), half_w)

	for iy in range(GameSession.terrain_height + 1):
		var y := float(iy * cell)
		_draw_quad(Vector2(0.0, y), Vector2(float(w), y), Vector2(0.0, 1.0), half_w)


func _draw_quad(from: Vector2, to: Vector2, perp: Vector2, half_w: float) -> void:
	var p0 := from - perp * half_w
	var p1 := from + perp * half_w
	var p2 := to + perp * half_w
	var p3 := to - perp * half_w

	var points := PackedVector2Array([p0, p1, p2, p3])
	var uvs := PackedVector2Array([
		p0 * uv_scale,
		p1 * uv_scale,
		p2 * uv_scale,
		p3 * uv_scale,
	])
	var colors := PackedColorArray([line_color, line_color, line_color, line_color])

	draw_polygon(points, colors, uvs)


func _check_phase_change() -> void:
	if (GameSession.current_phase == _prev_phase):
		return

	if GameSession.current_phase == "rebuild":
		_fade(true)
	elif GameSession.current_phase == "countdown" and _prev_phase == "place_weapons":
		_fade(false)
	elif GameSession.current_phase == "battle":
		_fade(false) # failsafe
	_prev_phase = GameSession.current_phase


func _fade(show: bool) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if show:
		visible = true
		_tween.tween_property(self , "modulate:a", 1.0, 2.0)
	else:
		_tween.tween_property(self , "modulate:a", 0.0, 2.0)
		_tween.tween_callback(func(): visible = false)
