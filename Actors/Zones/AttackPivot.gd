extends Position2D

class_name AttackPivot

# TODO: make it so you can load different projectiles
const RangedProjectile = preload("res://Weapons/RangedProjectile.tscn")

export var swingDegrees := 110.0
export(Array, Resource) var weaponStatsResources : Array

onready var weapon : Sprite = $WeaponRestingPos/Weapon
onready var restingPos := $WeaponRestingPos
onready var swipe := $Swipe
onready var tween := $WeaponTween
onready var collision := $WeaponHitbox/WeaponCollision
onready var weaponHitbox = $WeaponHitbox
onready var restingRotation = weapon.rotation
onready var weaponStats : WeaponStats

# TODO: Probably change these?
onready var meleeRestingCoord : Vector2 = restingPos.position
onready var meleeRestingRotation = weapon.rotation

var swordAnimDist
var tweenLength
var source : KinematicBody2D
var userStr: int = 0 setget setUserStr

func _ready():
	# Choose random weapon
	randomize()
	source = get_parent()
	weaponHitbox.setSource(source)
	weaponStats = weaponStatsResources[randi() % weaponStatsResources.size()]
	setWeapon(weaponStats)

# Rotate pivot to look at target position
func lookAtTarget(targetPos: Vector2):
	self.look_at(targetPos)
	
func setUserStr(sourceStr):
	userStr = sourceStr
	weaponHitbox.userStr = sourceStr
	print(weaponHitbox.userStr)

func startMeleeAttack(animLength: float):
	if weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
		self.tweenLength = animLength/2
		swipe.set_deferred("flip_h", not swipe.flip_h)
		tween.interpolate_property(weapon, "position", Vector2.ZERO, swordAnimDist, tweenLength)
		var endRotation = restingRotation + deg2rad(swingDegrees) 
		
		tween.interpolate_property(weapon, "rotation", restingRotation, endRotation, tweenLength)
		
		tween.start()
		
func startRangedAttack(sourceStr := 0):
	var rangedProjectile = RangedProjectile.instance()
	rangedProjectile.init(weaponStats, source, sourceStr)
	
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
		restingPos.set_deferred("position", Vector2(15, 0))
		weapon.set_deferred("rotation", deg2rad(45))
		weapon.set_deferred("z_index", 0)

func _on_WeaponTween_tween_completed():
	var backTween = $BackTween
	self.show_behind_parent = not self.show_behind_parent
	backTween.interpolate_property(weapon, "position", weapon.position, Vector2.ZERO, self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	backTween.interpolate_property(weapon, "rotation", weapon.rotation, restingRotation, self.tweenLength)
	backTween.start()
