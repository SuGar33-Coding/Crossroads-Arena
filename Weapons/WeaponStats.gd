extends Resource

class_name WeaponStats

enum WeaponType {
	MELEE,
	HEAVY,
	SPEAR,
	RANGED,
	AOE
}

export(String) var name = "Base Sword"
export(WeaponType) var weaponType = WeaponType.MELEE
export var damage : int = 10
export var knockbackValue : int = 350
export var radius : float = 15.5
export var length : float = 10.5
# Number of seconds between each attack
export var attackSpeed : float = .7
export var texture : Texture

# SFX
export var quickAttackSFX: AudioStream
export var longAttackSFX: AudioStream

# Ranged Weapon stuff
export var projectileTexture : Texture
export var projectileSpeed : float = 1500
export var projectileRange : float = 350
