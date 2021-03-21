extends Area2D

class_name WeaponHitbox

export var fromPlayer: bool = false
var damage
var knockbackValue
var hitboxOffset = 5
var weaponStats: WeaponStats

onready var collision := $WeaponCollision
onready var parryCollision := $ParryHitbox/ParryCollision

signal parried(area)

func getSourcePos() -> Vector2:
	return self.get_parent().global_position

func getKnockbackDirection(position) -> Vector2:
	return self.getSourcePos().direction_to(position)
	
func getKnockbackVector(position) -> Vector2:
	return self.getKnockbackDirection(position) * knockbackValue
	
func setWeapon(weapon : WeaponStats):
	weaponStats = weapon
	damage = weaponStats.damage
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
