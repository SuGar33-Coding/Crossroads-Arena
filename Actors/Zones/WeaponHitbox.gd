extends Area2D

class_name WeaponHitbox

export var weaponStatsResource : Resource

var damage
var knockbackValue
var hitboxOffset = 5

onready var weaponStats : WeaponStats = weaponStatsResource
onready var collision := $WeaponCollision

func _ready():
	damage = weaponStats.damage
	knockbackValue = weaponStats.knockbackValue
	
	collision.position.x = weaponStats.length/2 + weaponStats.radius + hitboxOffset
	var shape : CapsuleShape2D = CapsuleShape2D.new()
	shape.height = weaponStats.length
	shape.radius = weaponStats.radius
	collision.shape = shape
	

func getSource() -> Vector2:
	return self.get_parent().global_position

func getKnockbackDirection(position) -> Vector2:
	return self.getSource().direction_to(position)
	
func getKnockbackVector(position) -> Vector2:
	return self.getKnockbackDirection(position) * knockbackValue
