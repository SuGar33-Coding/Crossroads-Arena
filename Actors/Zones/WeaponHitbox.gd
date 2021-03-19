extends Area2D

class_name WeaponHitbox

export var weaponStatsResource : Resource

var damage
var knockbackValue
var hitboxOffset = 5

onready var weaponStats : WeaponStats = weaponStatsResource
onready var collision := $WeaponCollision
onready var parryCollision := $ParryHitbox/ParryCollision

signal parried(area)

func _ready():
	damage = weaponStats.damage
	knockbackValue = weaponStats.knockbackValue
	
	# Position the collision boxes to the right side of the player
	collision.position.x = weaponStats.length/2 + weaponStats.radius + hitboxOffset
	parryCollision.position.x = weaponStats.length/2 + weaponStats.radius + hitboxOffset
	
	# Create a new shape of the proper size for the loaded weapon
	var shape : CapsuleShape2D = CapsuleShape2D.new()
	shape.height = weaponStats.length
	shape.radius = weaponStats.radius
	collision.shape = shape
	parryCollision.shape = shape

func getSource() -> Vector2:
	return self.get_parent().global_position

func getKnockbackDirection(position) -> Vector2:
	return self.getSource().direction_to(position)
	
func getKnockbackVector(position) -> Vector2:
	return self.getKnockbackDirection(position) * knockbackValue

# Let everyone know that you've been parried
func parry(area : WeaponHitbox):
	emit_signal("parried", area)
