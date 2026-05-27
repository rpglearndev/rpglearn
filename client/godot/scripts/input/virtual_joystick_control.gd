extends Control
## Joystick virtual mínimo (touch + ratón). Emite dirección cardinal N/S/E/W o ZERO al soltar.

signal cardinal_changed(cardinal: Vector2i)

const _DEAD_PX := 14.0
const _MAX_KNOB_PX := 38.0

var _touch_index: int = -1
var _mouse_captured: bool = false
var _knob_offset: Vector2 = Vector2.ZERO
var _last_cardinal: Vector2i = Vector2i.ZERO


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_touch_index = st.index
			_update_from_local(st.position)
		else:
			if st.index == _touch_index:
				_touch_index = -1
				_release()
		accept_event()
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		if sd.index == _touch_index:
			_update_from_local(sd.position)
			accept_event()
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_mouse_captured = true
				_update_from_local(mb.position)
			else:
				if _mouse_captured:
					_mouse_captured = false
					_release()
			accept_event()
	elif event is InputEventMouseMotion and _mouse_captured:
		_update_from_local(event.position)
		accept_event()


func _release() -> void:
	_knob_offset = Vector2.ZERO
	_emit_cardinal(Vector2i.ZERO)


func _update_from_local(local_pos: Vector2) -> void:
	var center := size * 0.5
	var delta := local_pos - center
	var len := delta.length()
	if len < _DEAD_PX:
		_knob_offset = Vector2.ZERO
		_emit_cardinal(Vector2i.ZERO)
		return
	var dir := delta / len
	var extent := minf(_MAX_KNOB_PX, len)
	_knob_offset = dir * extent
	_emit_cardinal(_vector_to_cardinal(dir))


func _emit_cardinal(c: Vector2i) -> void:
	if c == _last_cardinal:
		queue_redraw()
		return
	_last_cardinal = c
	cardinal_changed.emit(c)
	queue_redraw()


func _vector_to_cardinal(v: Vector2) -> Vector2i:
	if absf(v.x) >= absf(v.y):
		return Vector2i.RIGHT if v.x > 0.0 else Vector2i.LEFT
	return Vector2i.DOWN if v.y > 0.0 else Vector2i.UP


func _draw() -> void:
	var center := size * 0.5
	var radius := mini(size.x, size.y) * 0.42
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.35, 0.35, 0.42, 0.85), 2.5, true)
	var knob_radius := minf(radius * 0.35, 18.0)
	draw_circle(center + _knob_offset, knob_radius, Color(0.55, 0.65, 0.95, 0.92))
