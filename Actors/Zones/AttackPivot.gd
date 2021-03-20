extends Position2D

class_name AttackPivot

export var swingDegrees := 110.0

onready var weapon := $MeleeRestingPos/Weapon
onready var restingPos := $MeleeRestingPos
onready var swipe := $Swipe
onready var tween := $WeaponTween
onready var collision := $WeaponHitbox/WeaponCollision
onready var weaponHitbox : WeaponHitbox = $WeaponHitbox
onready var restingRotation = weapon.rotation

var swordAnimDist
var tweenLength
var weaponStats : WeaponStats

func _ready():
	swordAnimDist = collision.global_position - restingPos.global_position
	swipe.frame = 0
	
	weaponStats = weaponHitbox.weaponStats
	weapon.texture = weaponStats.texture
	
	swipe.position = collision.position
	swipe.scale.x = .6 * (weaponStats.radius)/10
	swipe.scale.y = 1.5 * (weaponStats.length/2 + weaponStats.radius)/10

# Rotate pivot to look at target position
func lookAtTarget(targetPos: Vector2):
	self.look_at(targetPos)

func startAttack(animLength: float):
		self.tweenLength = animLength/2
		swipe.set_deferred("flip_h", not swipe.flip_h)
		tween.interpolate_property(weapon, "position", Vector2.ZERO, swordAnimDist, tweenLength)
		var endRotation = restingRotation + deg2rad(swingDegrees) 
		
		tween.interpolate_property(weapon, "rotation", restingRotation, endRotation, tweenLength)
		
		tween.interpolate_property(weapon, "z_index", weapon.z_index, weapon.z_index * -1, tweenLength)
		tween.start()


func _on_WeaponTween_tween_completed(_object, _key):
	var backTween = $BackTween
	
	backTween.interpolate_property(weapon, "position", weapon.position, Vector2.ZERO, self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	backTween.interpolate_property(weapon, "rotation", weapon.rotation, restingRotation, self.tweenLength)
	backTween.start()
