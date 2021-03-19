extends Position2D

export var swingDegrees := 80.0

onready var weapon := $MeleeRestingPos/Weapon
onready var restingPos := $MeleeRestingPos
onready var swipe := $Swipe
onready var tween := $WeaponTween
onready var collision := $Hitbox/HitboxCollision

onready var restingRotation = weapon.rotation

var swordAnimDist
var tweenLength

func _ready():
	swordAnimDist = collision.global_position - restingPos.global_position

# Rotate pivot to look at target position
func lookAtTarget(targetPos: Vector2):
	self.look_at(targetPos)

func startAttack(tweenLength: float):
		self.tweenLength = tweenLength
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
