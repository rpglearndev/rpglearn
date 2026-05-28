class_name LuaEditorIcons
extends RefCounted
## Iconos 20×20 para la barra del editor Lua (sin assets externos).


static func validate() -> ImageTexture:
	return _icon(_draw_check, Color(0.5, 0.95, 0.65))


static func run() -> ImageTexture:
	return _icon(_draw_play, Color(0.55, 0.85, 1.0))


static func stop() -> ImageTexture:
	return _icon(_draw_stop, Color(1.0, 0.45, 0.4))


static func manual() -> ImageTexture:
	return _icon(_draw_hand, Color(0.95, 0.85, 0.5))


static func close() -> ImageTexture:
	return _icon(_draw_close, Color(0.85, 0.88, 0.95))


static func _icon(draw_fn: Callable, color: Color) -> ImageTexture:
	var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	draw_fn.call(img, color)
	return ImageTexture.create_from_image(img)


static func _draw_play(img: Image, c: Color) -> void:
	for y in range(5, 15):
		for x in range(7, 16):
			if x - 7 < (y - 5) * 0.55 and x - 7 < (14 - y) * 0.55:
				img.set_pixel(x, y, c)


static func _draw_stop(img: Image, c: Color) -> void:
	for y in range(6, 14):
		for x in range(6, 14):
			img.set_pixel(x, y, c)


static func _draw_check(img: Image, c: Color) -> void:
	var pts := [Vector2i(4, 10), Vector2i(8, 14), Vector2i(16, 5)]
	for i in pts.size() - 1:
		_line(img, pts[i], pts[i + 1], c)


static func _draw_hand(img: Image, c: Color) -> void:
	for y in range(4, 16):
		for x in range(8, 13):
			img.set_pixel(x, y, c)
	for y in range(6, 10):
		img.set_pixel(6, y, c)
		img.set_pixel(13, y, c)


static func _draw_close(img: Image, c: Color) -> void:
	_line(img, Vector2i(5, 5), Vector2i(14, 14), c)
	_line(img, Vector2i(14, 5), Vector2i(5, 14), c)


static func _line(img: Image, a: Vector2i, b: Vector2i, c: Color) -> void:
	var d := b - a
	var steps := maxi(absi(d.x), absi(d.y))
	if steps == 0:
		img.set_pixel(a.x, a.y, c)
		return
	for i in steps + 1:
		var t := float(i) / float(steps)
		var p := Vector2i(int(round(lerpf(float(a.x), float(b.x), t))), int(round(lerpf(float(a.y), float(b.y), t))))
		for ox in [-1, 0, 1]:
			for oy in [-1, 0, 1]:
				var q := p + Vector2i(ox, oy)
				if q.x >= 0 and q.y >= 0 and q.x < 20 and q.y < 20:
					img.set_pixel(q.x, q.y, c)
