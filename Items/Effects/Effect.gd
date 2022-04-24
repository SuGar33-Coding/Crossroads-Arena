# Class of different effects that can be applied by weapons, consumables, armor, etc
class_name Effect extends Resource

""" Value Key:
Heal: Should be the number of HP that heals per tick
POSION & BLEED: should be number of HP lost per tick
STR, CON, DEX: number that the stat is increased by (can be made negative for decrease)
SLOW: Percentage slow
ARMOR_SHRED: Amount of armor to shred (1 to 1 with armor value)
"""
enum EffectType {
	HEAL,
	POISON,
	BLEED,
	STR,
	CON,
	DEX,
	SLOW,
	ARMOR_SHRED,
	ARMOR_BUFF
}

export(EffectType) var effectType
export var amount := 10
export var totalTicks := 1
export var icon : Texture
