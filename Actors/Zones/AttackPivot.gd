extends Position2D

class_name AttackPivot

# TODO: make it so you can load different projectiles
const RangedProjectile = preload("res://Weapons/RangedProjectile.tscn")
const AttackSignal = preload("res://FX/AttackSignal.tscn")

export var swingDegrees := 110.0
export(Array, Resource) var weaponStatsResources : Array

onready var weapon : Sprite = $WeaponRestingPos/Weapon
onready var restingPos := $WeaponRestingPos
onready var swipe := $Swipe
onready var tween := $WeaponTween
onready var backTween := $BackTween
onready var collision := $WeaponHitbox/WeaponCollision
onready var weaponHitbox = $WeaponHitbox
onready var restingRotation = weapon.rotation
onready var weaponStats : WeaponStats
onready var attackTimer := $AttackTimer
onready var attackSignalPos := $WeaponRestingPos/AttackSignalPos

# TODO: Probably change these?
onready var meleeRestingCoord : Vector2 = restingPos.position
onready var meleeRestingRotation = weapon.rotation

var swordAnimDist
var tweenLength
var source : KinematicBody2D
var userStr: int = 0 setget setUserStr
var weaponMat: ShaderMaterial
var shaderTime: = 0.0

func _ready():
	# Choose random weapon
	randomize()
	source = get_parent()
	weaponHitbox.setSource(source)
	weaponStats = weaponStatsResources[randi() % weaponStatsResources.size()]
	setWeapon(weaponStats)
	
	# Get a local copy of weapon mat
	weapon.material = weapon.material.duplicate()
	weaponMat = weapon.material

func _process(delta):
	# If the sheen shader is active, increment it from the beginning
	var shaderActive: bool = weaponMat.get_shader_param("active")
	if shaderActive:
		weaponMat.set_shader_param("time", shaderTime)
		shaderTime += delta
	else:
		shaderTime = 0.0

# Rotate pivot to look at target position
func lookAtTarget(targetPos: Vector2):
	self.look_at(targetPos)
	
func setUserStr(sourceStr):
	userStr = sourceStr
	weaponHitbox.userStr = sourceStr

func startMeleeAttack(animLength: float):
	weaponMat.set_shader_param("active", false)
	
	if weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
		self.tweenLength = animLength/2
		swipe.set_deferred("flip_h", not swipe.flip_h)
		tween.interpolate_property(weapon, "position", Vector2.ZERO, swordAnimDist, tweenLength)
		var endRotation = restingRotation + deg2rad(swingDegrees) 
		
		tween.interpolate_property(weapon, "rotation", restingRotation, endRotation, tweenLength)
		
		tween.start()
		
func playAttackSignal(windUpTime: float):
	var atkSignal : Particles2D = AttackSignal.instance()
	atkSignal.position = attackSignalPos.position
	restingPos.add_child(atkSignal)
	atkSignal.set_deferred("emitting", true)
	
	# Activate the sheen shader
	weaponMat.set_shader_param("frequency", 1.0 / windUpTime)
	weaponMat.set_shader_param("active", true)

		
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

# TODO: Can set tween delay rather than making multiple tweens
func _on_WeaponTween_tween_completed():
	self.show_behind_parent = not self.show_behind_parent
	backTween.interpolate_property(weapon, "position", weapon.position, Vector2(-15, 5), self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	backTween.interpolate_property(weapon, "rotation", weapon.rotation, restingRotation - deg2rad(50), self.tweenLength)
	
	# Add the .007 so if player is spam clicking it feels more fluid/no stop on swing
	backTween.interpolate_property(weapon, "position", Vector2(-15, 5), Vector2.ZERO, attackTimer.time_left + .007, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, self.tweenLength)
	backTween.interpolate_property(weapon, "rotation", restingRotation - deg2rad(50), restingRotation, attackTimer.time_left + .007, self.tweenLength)
	
	backTween.start()

