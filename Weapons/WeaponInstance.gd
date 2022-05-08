class_name WeaponInstance extends ItemInstance


var weaponType
var weaponTexture : Texture
var damage := 10
var armorPierce := 0
var knockbackValue := 350
var radius := 15.5
var length := 10.5
# Number of seconds between each attack
var attackSpeed := 0.7

var effectResources := []
# SFX
var quickAttackSFX: AudioStream
var longAttackSFX: AudioStream

# Ranged Weapon stuff
var projectileTexture : Texture
var projectileSpeed : float = 1500
var projectileRange : float = 350

# AOE Stuff
var aoeEffect : Resource
var aoeNumberOfTicks := 3
var aoeLifetime := 3.0
var aoeType
var instantApplySustain : bool

func _ready():
	itemType = "weapon"

func _setResource(newResource):
	._setResource(newResource)
	var weaponStats = self.resource as WeaponStats
	weaponType = weaponStats.weaponType
	if weaponStats.weaponTexture == null:
		weaponTexture = weaponStats.texture
	else:
		weaponTexture = weaponStats.weaponTexture
	flip = weaponStats.flip
	damage = weaponStats.damage
	armorPierce = weaponStats.armorPierce
	knockbackValue = weaponStats.knockbackValue
	radius = weaponStats.radius
	length = weaponStats.length
	attackSpeed = weaponStats.attackSpeed
	
	effectResources = weaponStats.effectResources
	
	quickAttackSFX = weaponStats.quickAttackSFX
	longAttackSFX = weaponStats.longAttackSFX
	
	projectileTexture = weaponStats.projectileTexture
	projectileSpeed = weaponStats.projectileSpeed
	projectileRange = weaponStats.projectileRange
	
	aoeEffect = weaponStats.aoeEffect
	aoeNumberOfTicks = weaponStats.aoeNumberOfTicks
	aoeLifetime = weaponStats.aoeLifetime
	
	aoeType = weaponStats.aoeType
	instantApplySustain = weaponStats.instantApplySustain

func _setModifier(newResource : Modifier):
	._setModifier(newResource)
	var weaponStats = self.resource as WeaponStats
	var weaponMod = newResource as Modifier
	
	damage = weaponStats.damage * weaponMod.damageModifier
	attackSpeed = weaponStats.attackSpeed / weaponMod.speedModifier
	knockbackValue = weaponStats.knockbackValue * weaponMod.knockbackModifier

