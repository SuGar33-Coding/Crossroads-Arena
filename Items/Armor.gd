class_name Armor extends Item

enum Type {
	Head, Chest, Feet
}

export (Type) var type
# Texture to be used on top of character sprite
export (Texture) var characterTexture
export (int) var defenseValue
# A multiplier to wearer's speed
export (float) var speedModifier
