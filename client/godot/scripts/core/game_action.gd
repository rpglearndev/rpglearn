class_name GameAction
extends RefCounted
## Acción mayor encolable para un tick (máx. una por tick).

enum Type {
	MOVE,
	ATTACK,
	USE_ITEM,
	LOOT,
	TRADE,
}

var type: Type = Type.MOVE
var entity_id: StringName = &"player"
var direction: Vector2i = Vector2i.ZERO


static func move(entity_id: StringName, direction: Vector2i) -> GameAction:
	var action := GameAction.new()
	action.type = Type.MOVE
	action.entity_id = entity_id
	action.direction = direction
	return action


static func is_major_type(t: Type) -> bool:
	return t in [Type.MOVE, Type.ATTACK, Type.USE_ITEM, Type.LOOT, Type.TRADE]
