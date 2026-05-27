class_name MobVisualSpawner
extends RefCounted
## Sprites de mobs en el mapa (US-020 visibilidad; arte final US-021).

const MixelSpriteLoader := preload("res://scripts/world/mixel_sprite_loader.gd")

var _sprites: Dictionary = {}


func build(parent: Node2D, world, combat, tile_size: int) -> void:
	clear(parent)
	if combat == null:
		return
	for entity_id: StringName in combat.list_mob_entity_ids():
		var sprite := Sprite2D.new()
		sprite.name = str(entity_id)
		var mob_id := combat.get_mob_id(entity_id)
		sprite.texture = MixelSpriteLoader.mob_placeholder(mob_id)
		parent.add_child(sprite)
		_sprites[entity_id] = sprite
	sync(world, combat, tile_size)


func sync(world, combat, tile_size: int) -> void:
	if combat == null:
		return
	for entity_id: StringName in _sprites:
		var sprite: Sprite2D = _sprites[entity_id]
		if not combat.is_entity_alive(entity_id):
			sprite.visible = false
			continue
		sprite.visible = true
		var cell: Vector2i = world.get_entity_position(entity_id)
		sprite.position = Vector2(cell.x * tile_size + tile_size / 2, cell.y * tile_size + tile_size / 2)
		sprite.z_index = int(sprite.position.y)


func clear(parent: Node2D) -> void:
	for key in _sprites:
		var sprite: Sprite2D = _sprites[key]
		if is_instance_valid(sprite):
			sprite.queue_free()
	_sprites.clear()
	for child in parent.get_children():
		if str(child.name).begins_with("mob_"):
			child.queue_free()
