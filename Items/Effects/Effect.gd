# Class of different effects that can be applied by weapons, consumables, armor, etc
class_name Effect extends Resource

enum EffectType {
	HEAL,
	POISON,
	BLEED,
	STR,
	CON,
	DEX
}

export(EffectType) var effectType
export var amount := 10
export var totalTicks := 1
