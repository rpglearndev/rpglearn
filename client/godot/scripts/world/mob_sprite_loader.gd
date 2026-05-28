class_name MobSpriteLoader
extends RefCounted
## Sprites MVP por mob_id (US-021). Procedural 24×24 hasta arte DB32.

const SIZE := 24

static var _cache: Dictionary = {}


static func texture_for(mob_id: String) -> Texture2D:
	if _cache.has(mob_id):
		return _cache[mob_id]
	var tex: ImageTexture
	match mob_id:
		"mob_slime":
			tex = _make_slime()
		"mob_wolf":
			tex = _make_wolf()
		"mob_bandit":
			tex = _make_bandit()
		_:
			tex = _make_slime()
	_cache[mob_id] = tex
	return tex


static func _make_slime() -> ImageTexture:
	var img := _blank()
	var body := Color(0.28, 0.88, 0.42)
	var shine := Color(0.55, 1.0, 0.65, 0.9)
	_ellipse(img, Vector2(12, 14), 9, 7, body)
	_ellipse(img, Vector2(9, 11), 3, 2, shine)
	_dot(img, 8, 13, Color(0.1, 0.25, 0.12))
	_dot(img, 15, 13, Color(0.1, 0.25, 0.12))
	return ImageTexture.create_from_image(img)


static func _make_wolf() -> ImageTexture:
	var img := _blank()
	var fur := Color(0.45, 0.48, 0.52)
	var dark := Color(0.28, 0.3, 0.34)
	_ellipse(img, Vector2(13, 14), 10, 6, fur)
	_triangle(img, Vector2i(6, 8), Vector2i(9, 3), Vector2i(11, 9), dark)
	_triangle(img, Vector2i(16, 9), Vector2i(19, 3), Vector2i(21, 9), dark)
	_dot(img, 17, 13, Color(0.9, 0.85, 0.2))
	_dot(img, 19, 13, Color(0.9, 0.85, 0.2))
	return ImageTexture.create_from_image(img)


static func _make_bandit() -> ImageTexture:
	var img := _blank()
	var cloak := Color(0.72, 0.22, 0.2)
	var skin := Color(0.85, 0.72, 0.58)
	var pants := Color(0.35, 0.32, 0.38)
	_rect(img, 8, 6, 8, 7, skin)
	_rect(img, 6, 12, 12, 9, cloak)
	_rect(img, 7, 20, 4, 3, pants)
	_rect(img, 13, 20, 4, 3, pants)
	_dot(img, 10, 9, Color(0.15, 0.12, 0.1))
	_dot(img, 14, 9, Color(0.15, 0.12, 0.1))
	return ImageTexture.create_from_image(img)


static func _blank() -> Image:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	return img


static func _dot(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < SIZE and y < SIZE:
		img.set_pixel(x, y, c)


static func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for py in range(y, y + h):
		for px in range(x, x + w):
			_dot(img, px, py, c)


static func _ellipse(img: Image, center: Vector2, rx: float, ry: float, c: Color) -> void:
	for py in SIZE:
		for px in SIZE:
			var dx := (float(px) - center.x) / rx
			var dy := (float(py) - center.y) / ry
			if dx * dx + dy * dy <= 1.0:
				_dot(img, px, py, c)


static func _triangle(img: Image, a: Vector2i, b: Vector2i, c: Vector2i, col: Color) -> void:
	var min_x := mini(mini(a.x, b.x), c.x)
	var max_x := maxi(maxi(a.x, b.x), c.x)
	var min_y := mini(mini(a.y, b.y), c.y)
	var max_y := maxi(maxi(a.y, b.y), c.y)
	for py in range(min_y, max_y + 1):
		for px in range(min_x, max_x + 1):
			if _point_in_triangle(Vector2(px, py), Vector2(a), Vector2(b), Vector2(c)):
				_dot(img, px, py, col)


static func _point_in_triangle(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> bool:
	var d1 := _sign(p, a, b)
	var d2 := _sign(p, b, c)
	var d3 := _sign(p, c, a)
	var has_neg := d1 < 0 or d2 < 0 or d3 < 0
	var has_pos := d1 > 0 or d2 > 0 or d3 > 0
	return not (has_neg and has_pos)


static func _sign(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)
