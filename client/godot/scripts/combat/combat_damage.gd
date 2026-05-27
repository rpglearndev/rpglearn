class_name CombatDamage
extends RefCounted
## Daño determinista desde JSON (plan: weapon + skill * scale * class * level - defense).


static func compute(attacker: Dictionary, target_defense: int, config: CombatConfig) -> int:
	var f := config.formula
	var weapon_base := int(f.get("weapon_base", 0))
	var weapon_scale := float(f.get("weapon_scale", 1.0))
	var skill := int(attacker.get("skill", 0))
	var weapon_attack := int(attacker.get("weapon_attack", 0))
	var level := int(attacker.get("level", 1))
	var class_id := str(attacker.get("class", "warrior"))
	var mults: Dictionary = f.get("class_multipliers", {})
	var class_mult := float(mults.get(class_id, 1.0))
	var divisor := int(f.get("level_factor_divisor", 100))
	var raw := (float(weapon_base + weapon_attack) + weapon_scale * float(skill)) * class_mult
	raw *= 1.0 + float(level) / float(divisor)
	var damage := int(floor(raw)) - target_defense
	return maxi(config.min_damage, damage)


static func skill_for_class(class_id: String, profile: Dictionary) -> int:
	match class_id:
		"mage":
			return int(profile.get("magic_skill", 0))
		"archer":
			return int(profile.get("ranged_skill", 0))
		_:
			return int(profile.get("melee_skill", 0))
