class_name WeaponStats extends Item

enum WeaponType {
	MELEE,
	SWORD,
	HEAVY,
	SPEAR,
	RANGED,
	AOE
}

enum AoeType {
	IMPACT,
	SUSTAIN,
	IMPACT_AND_SUSTAIN
}

export(WeaponType) var weaponType = WeaponType.MELEE
export(Texture) var weaponTexture
export(int) var damage = 10
# Percentage of armor that damage goes through
export(int) var armorPierce = 0
export(int) var knockbackValue = 350
export(float) var radius = 15.5
export(float) var length = 10.5
# Number of seconds between each attack
export(float) var attackSpeed = .7

export(Array, Resource) var effectResources
# SFX
export(AudioStream) var quickAttackSFX
export(AudioStream) var longAttackSFX

# Ranged Weapon stuff
export(Texture) var projectileTexture
export(float) var projectileSpeed = 1500
export(float) var projectileRange = 350

# AOE Stuff
export(Resource) var aoeEffect
export(int) var aoeNumberOfTicks = 3
export(float) var aoeLifetime = 3.0
export(AoeType) var aoeType = AoeType.IMPACT
# whether or not to instantly do one of the sustain ticks on aoe start
export(bool) var instantApplySustain = false
# aoe angle should be < 0 if you don't want it to rotate
#export var aoeAngle : float = -1.0
