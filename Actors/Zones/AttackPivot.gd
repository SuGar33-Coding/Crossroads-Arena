extends Position2D

class_name AttackPivot

const RangedProjectile = preload("res://Weapons/RangedProjectile.tscn")

export var swingDegrees := 110.0
export var weaponStatsResource : Resource

onready var weapon : Sprite = $WeaponRestingPos/Weapon
onready var restingPos := $WeaponRestingPos
onready var swipe := $Swipe
onready var tween := $WeaponTween
onready var collision := $WeaponHitbox/WeaponCollision
onready var weaponHitbox = $WeaponHitbox
onready var restingRotation = weapon.rotation
onready var weaponStats : WeaponStats = weaponStatsResource

# TODO: Probably change these?
onready var meleeRestingCoord : Vector2 = restingPos.position
onready var meleeRestingRotation = weapon.rotation

var swordAnimDist
var tweenLength


func _ready():
	setWeapon(weaponStats)

# Rotate pivot to look at target position
func lookAtTarget(targetPos: Vector2):
	self.look_at(targetPos)

func startMeleeAttack(animLength: float):
	if weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
		self.tweenLength = animLength/2
		swipe.set_deferred("flip_h", not swipe.flip_h)
		tween.interpolate_property(weapon, "position", Vector2.ZERO, swordAnimDist, tweenLength)
		var endRotation = restingRotation + deg2rad(swingDegrees) 
		
		tween.interpolate_property(weapon, "rotation", restingRotation, endRotation, tweenLength)
		
		tween.start()
		
func startRangedAttack(fromPlayer := false):
	var rangedProjectile = RangedProjectile.instance()
	rangedProjectile.init(weaponStats, fromPlayer)
	
	var world = get_tree().current_scene
	# Have to set it before you add it as a child otherwise the room area's think you are exiting them
	rangedProjectile.global_position = restingPos.global_position
	world.add_child(rangedProjectile)
	rangedProjectile.fire(restingPos.global_position, self.global_rotation)

func setWeapon(weaponStats : WeaponStats):
	self.weaponStats = weaponStats
	weaponHitbox.setWeapon(weaponStats)
	weapon.texture = weaponStats.texture
	
	if weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
		restingPos.position = meleeRestingCoord
		weapon.rotation = restingRotation
		swordAnimDist = collision.position - restingPos.position
		swipe.frame = 0
		
		swipe.position = collision.position
		# Ratios I found from doing testing with OG sprite
		swipe.scale.x = .6 * (weaponStats.radius)/10
		swipe.scale.y = 1.5 * (weaponStats.length/2 + weaponStats.radius)/10
		
	else:
		restingPos.position = Vector2(15, 0)
		weapon.rotation = deg2rad(45)
		weapon.z_index = 0

func _on_WeaponTween_tween_completed():
	var backTween = $BackTween
	self.show_behind_parent = not self.show_behind_parent
	backTween.interpolate_property(weapon, "position", weapon.position, Vector2.ZERO, self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	backTween.interpolate_property(weapon, "rotation", weapon.rotation, restingRotation, self.tweenLength)
	backTween.start()
