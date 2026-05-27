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
