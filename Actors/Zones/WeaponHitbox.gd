extends Hitbox

class_name WeaponHitbox

var fromPlayer: bool = false
var userStr: int = 0 setget setUserStr
var source
var hitboxOffset = 5
var weaponStats: WeaponStats
var weaponDamage: int

onready var collision := $WeaponCollision
onready var parryCollision := $ParryHitbox/ParryCollision

signal parried(area)

func setSource(newSource, sourceStr := 0):
	self.source = newSource
	fromPlayer = (self.source.name == "Player")
	setUserStr(sourceStr)
	
func setUserStr(value):
	userStr = value
	self.damage = self.weaponDamage *  pow(PlayerStats.strRatio, self.userStr)

func getSource():
	return self.source

func getSourcePos() -> Vector2:
	return self.source.global_position
	
func setWeapon(weapon : WeaponStats):
	weaponStats = weapon
	weaponDamage = weapon.damage
	damage = self.weaponDamage *  pow(PlayerStats.strRatio, self.userStr)
	knockbackValue = weaponStats.knockbackValue
		
	if weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
		# Position the collision boxes to the right side of the player
		collision.position.x = weaponStats.length/2 + weaponStats.radius + hitboxOffset
		parryCollision.position.x = weaponStats.length/2 + weaponStats.radius + hitboxOffset
		
	else:
		#is ranged, no local weapon collision
		collision.position.x = 0
		parryCollision.position.x = 0
		
	# Create a new shape of the proper size for the loaded weapon
	var shape : CapsuleShape2D = CapsuleShape2D.new()
	shape.height = weaponStats.length
	shape.radius = weaponStats.radius
	collision.shape = shape
	parryCollision.shape = shape

# Let everyone know that you've been parried
func parry(area : WeaponHitbox):
	emit_signal("parried", area)
