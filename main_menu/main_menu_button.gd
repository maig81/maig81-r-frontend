extends Button

@onready var underline = $Underline
@onready var line_h = $Underline/Line2D
@onready var line_r = $Underline/Line2D3
@onready var line_l = $Underline/Line2D2

const DRAW_DUR_H := 0.4
const DRAW_DUR_V := 0.12
const ERASE_DUR_H := 0.3
const ERASE_DUR_V := 0.08

var _tween: Tween
var _h_t := 0.0
var _r_t := 0.0
var _l_t := 0.0

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_set_h(0.0)
	_set_r(0.0)
	_set_l(0.0)

func _set_h(t: float) -> void:
	_h_t = t
	line_h.points = PackedVector2Array([Vector2(0, 0), Vector2(700.0 * t, 0)])

func _set_r(t: float) -> void:
	_r_t = t
	line_r.points = PackedVector2Array([Vector2(0, 0), Vector2(0, 20.0 * t)])

func _set_l(t: float) -> void:
	_l_t = t
	line_l.points = PackedVector2Array([Vector2(0, 0), Vector2(0, 20.0 * t)])

func _animate_draw() -> void:
	if _tween:
		_tween.kill()
	underline.visible = true
	underline.modulate.a = 1.0
	_tween = create_tween()
	_tween.tween_interval(0.03)
	_tween.tween_method(_set_h, 0.0, 1.0, DRAW_DUR_H).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(0.03)
	_tween.tween_method(_set_l, 0.0, 1.0, DRAW_DUR_V).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(0.02)
	_tween.tween_method(_set_r, 0.0, 1.0, DRAW_DUR_V).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func _animate_erase() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if _r_t > 0.0:
		_tween.tween_method(_set_r, _r_t, 0.0, ERASE_DUR_V * _r_t).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	if _l_t > 0.0:
		_tween.tween_method(_set_l, _l_t, 0.0, ERASE_DUR_V * _l_t).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	if _h_t > 0.0:
		_tween.tween_method(_set_h, _h_t, 0.0, ERASE_DUR_H * _h_t).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	_tween.tween_callback(func(): underline.visible = false)

func _on_mouse_entered():
	_animate_draw()

func _on_mouse_exited():
	_animate_erase()
