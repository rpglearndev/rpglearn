class_name WorldZone
extends RefCounted

enum Id {
	GREENFIELD,
	RIVERTON,
	OUTSKIRTS,
}


static func id_to_string(zone_id: Id) -> String:
	match zone_id:
		Id.GREENFIELD:
			return "greenfield"
		Id.RIVERTON:
			return "riverton"
		Id.OUTSKIRTS:
			return "outskirts"
	return "unknown"
