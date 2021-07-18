class_name WeaponInstance extends ItemInstance


var weaponType
var weaponTexture : Texture
var damage : int = 10
var knockbackValue : int = 350
var radius : float = 15.5
var length : float = 10.5
# Number of seconds between each attack
var attackSpeed : float = .7

# SFX
var quickAttackSFX: AudioStream
var longAttackSFX: AudioStream

# Ranged Weapon stuff
var projectileTexture : Texture
var projectileSpeed : float = 1500
var projectileRange : float = 350

# AOE Stuff
var aoeEffect : Resource
var aoeNumberOfTicks : int = 3
var aoeLifetime : float = 3.0
# whether or not to instantly do one of the ticks on aoe start
var instantTick := false

func _setResource(newResource):
	._setResource(newResource)
	var weaponStats = self.resource as WeaponStats
	weaponType = weaponStats.weaponType
	weaponTexture = weaponStats.weaponTexture
	damage = weaponStats.damage
	knockbackValue = weaponStats.knockbackValue
	radius = weaponStats.radius
	length = weaponStats.length
	attackSpeed = weaponStats.attackSpeed
	
	quickAttackSFX = weaponStats.quickAttackSFX
	longAttackSFX = weaponStats.longAttackSFX
	
	projectileTexture = weaponStats.projectileTexture
	projectileSpeed = weaponStats.projectileSpeed
	projectileRange = weaponStats.projectileRange
	
	aoeEffect = weaponStats.aoeEffect
	aoeNumberOfTicks = weaponStats.aoeNumberOfTicks
	aoeLifetime = weaponStats.aoeLifetime
	
	instantTick = weaponStats.instantTick

func _setModifier(newResource : Modifier):
	._setModifier(newResource)
	var weaponStats = self.resource as WeaponStats
	var weaponMod = newResource as Modifier
	
	damage = weaponStats.damage * weaponMod.damageModifier
	attackSpeed = weaponStats.attackSpeed * weaponMod.speedModifier
	knockbackValue = weaponStats.knockbackValue * weaponMod.knockbackModifier

