class_name Item extends Resource

enum RARITY {
	UBIQUITOS,
	COMMON,
	UNCOMMON,
	RARE,
	VERY_RARE,
	EXOTIC,
	LEGENDARY
}

export (String) var name = ""
export (int) var value
export (Texture) var texture
export (bool) var flip = false
export (Array, Resource) var modifiers = []
export (RARITY) var rarity = RARITY.UBIQUITOS
