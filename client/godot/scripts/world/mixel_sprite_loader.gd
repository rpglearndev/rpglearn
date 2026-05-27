class_name MixelSpriteLoader
extends RefCounted
## Carga PNG Mixel en runtime (headless + editor sin .import).

const ASSETS_ROOT := "res://assets/mixel/"


static func load_texture(path: String) -> Texture2D:
	var file_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(file_path):
		return null
	var image := Image.load_from_file(file_path)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


static func load_atlas_region(atlas_path: String, region: Rect2i) -> AtlasTexture:
	var base := load_texture(atlas_path)
	if base == null:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = base
	atlas.region = Rect2(region.position, region.size)
	return atlas


static func player_idle_front() -> Texture2D:
	var path := ASSETS_ROOT + "MainCharacter v.1.0/MainC_Idle_Front.PNG"
	var file_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(file_path):
		return null
	var image := Image.load_from_file(file_path)
	if image == null:
		return null
	var frame_w := 32
	if image.get_width() > frame_w:
		image = image.get_region(Rect2i(0, 0, frame_w, mini(frame_w, image.get_height())))
	return ImageTexture.create_from_image(image)


static func mob_placeholder(mob_id: String) -> Texture2D:
	var color := Color(0.45, 0.85, 0.35)
	match mob_id:
		"mob_slime":
			color = Color(0.35, 0.92, 0.45)
		"mob_wolf":
			color = Color(0.55, 0.55, 0.6)
		"mob_bandit":
			color = Color(0.85, 0.35, 0.3)
	var size := 22
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var center := Vector2i(size / 2, size / 2)
	var radius := size / 2 - 2
	for y in size:
		for x in size:
			if Vector2i(x, y).distance_to(center) <= float(radius):
				img.set_pixel(x, y, color)
	return ImageTexture.create_from_image(img)
