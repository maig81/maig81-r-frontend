class_name PencilLine

extends Node2D


@export var points: PackedVector2Array
@export var line_width: float = 1.0
@export var uv_scale: float = 0.004
@export var smoothstep_lo: float = 0.2
@export var smoothstep_hi: float = 0.9
@export var pencil_alpha_min: float = 0.4
@export var pencil_alpha_max: float = 0.5
@export var line_color: Color = Color(0.0, 0.0, 0.0, 0.5)
var _noise_tex: Texture2D
var _shader: Shader
var _mat: ShaderMaterial

func _ready() -> void:
	_noise_tex = load("res://game/terrain/pencil_line_noise.tres")
	_shader = load("res://game/terrain/pencil_line.gdshader")
	_mat = ShaderMaterial.new()
	_mat.shader = _shader
	_mat.set_shader_parameter("noise_texture", _noise_tex)
	_mat.set_shader_parameter("smoothstep_lo", smoothstep_lo)
	_mat.set_shader_parameter("smoothstep_hi", smoothstep_hi)
	_mat.set_shader_parameter("pencil_alpha_min", pencil_alpha_min)
	_mat.set_shader_parameter("pencil_alpha_max", pencil_alpha_max)
	material = _mat

	_noise_tex.changed.connect(queue_redraw)


func _draw() -> void:
	var count := points.size()
	if count < 2:
		return

	var half_w := line_width * 0.5
	for i in count:
		var a := points[i]
		var b := points[(i + 1) % count]
		if a == b:
			continue
		var perp := (b - a).normalized().orthogonal()
		var p0 := a - perp * half_w
		var p1 := a + perp * half_w
		var p2 := b + perp * half_w
		var p3 := b - perp * half_w
		var quad := PackedVector2Array([p0, p1, p2, p3])
		var uvs := PackedVector2Array([
			p0 * uv_scale,
			p1 * uv_scale,
			p2 * uv_scale,
			p3 * uv_scale,
		])
		var colors := PackedColorArray([line_color, line_color, line_color, line_color])
		draw_polygon(quad, colors, uvs)