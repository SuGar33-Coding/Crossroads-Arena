class_name AttackPivot extends Position2D

# TODO: make it so you can load different projectiles
const RangedProjectileScene = preload("res://Weapons/RangedProjectile.tscn")
const AreaOfEffectScene = preload("res://Weapons/AreaOfEffect.tscn")
const AttackSignalScene = preload("res://FX/AttackSignal.tscn")

enum MeleeAttackType {
	QUICK,
	LONG
}

export var swingDegrees := 110.0
export(Array, Resource) var weaponStatsResources : Array

onready var weaponSprite : Sprite = $WeaponRestingPos/Weapon
onready var restingPos := $WeaponRestingPos
onready var swipe := $Swipe
onready var tween := $WeaponTween
onready var backTween := $BackTween
onready var weaponCollision := $WeaponHitbox/WeaponCollision
onready var weaponHitbox = $WeaponHitbox
onready var restingRotation = weaponSprite.rotation
onready var weaponStats : WeaponStats
onready var attackTimer := $AttackTimer
onready var attackSignalPos := $WeaponRestingPos/AttackSignalPos
onready var quickSfx: AudioStreamPlayer2D = $QuickSFX
onready var longSfx: AudioStreamPlayer2D = $LongSFX

# TODO: Probably change these?
onready var meleeRestingCoord : Vector2 = restingPos.position
onready var meleeRestingRotation = weaponSprite.rotation

var swordAnimDist
var tweenLength
var source : KinematicBody2D
var userStr: int = 0 setget setUserStr
var weaponMat: ShaderMaterial
var shaderTime: = 0.0
var returnRot := 0.0

func _ready():
	# Choose random weapon
	randomize()
	source = get_parent()
	weaponHitbox.setSource(source)
	weaponStats = weaponStatsResources[randi() % weaponStatsResources.size()]
	setWeapon(weaponStats)
	
	# Set the weapon's SFX
	quickSfx.stream = weaponStats.quickAttackSFX
	longSfx.stream = weaponStats.longAttackSFX
	
	tween.connect("tween_all_completed", self, "_on_WeaponTween_tween_completed")
	
	# Get a local copy of weapon mat
	weaponSprite.material = weaponSprite.material.duplicate()
	weaponMat = weaponSprite.material
	

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

func startMeleeAttack(animLength: float, type = MeleeAttackType.QUICK):
	# Start sheen shader
	weaponMat.set_shader_param("active", false)
	
	# Play swoosh
	match type:
		MeleeAttackType.QUICK:
			quickSfx.play()
		MeleeAttackType.LONG:
			longSfx.play()
	
	
	#if weaponStats.weaponType == WeaponStats.WeaponType.MELEE or weaponStats.weaponType == WeaponStats.WeaponType.HEAVY or weaponStats.weaponType == WeaponStats.WeaponType.SPEAR:
	self.tweenLength = animLength/2
	swipe.set_deferred("flip_h", not swipe.flip_h)
	tween.interpolate_property(weaponSprite, "position", weaponSprite.position, swordAnimDist, tweenLength)
	var endRotation = restingRotation + deg2rad(swingDegrees) 
	
	tween.interpolate_property(weaponSprite, "rotation", weaponSprite.rotation, endRotation, tweenLength)
	
	tween.start()
		
func playAttackSignal(windUpTime: float, shading: bool = true):
	var atkSignal : Particles2D = AttackSignalScene.instance()
	atkSignal.position = attackSignalPos.position
	restingPos.add_child(atkSignal)
	atkSignal.set_deferred("emitting", true)
	
	# Activate the sheen shader
	if shading:
		weaponMat.set_shader_param("frequency", 1.0 / windUpTime)
		weaponMat.set_shader_param("active", true)

# Starts a ranged attack, creating a projectile in the given direction
# Accuracy measures how close the user was to getting a perfectly timed attack
# By default (for NPCs) this will be the threshold at which you do normal damage
# Projectile speed also scales with accuracy
func startRangedAttack(sourceStr := 0, accuracy := RangedProjectile.NORMAL):
	var rangedProjectile = RangedProjectileScene.instance()
	rangedProjectile.init(weaponStats, source, sourceStr, accuracy)
	
	var world = get_tree().current_scene
	# Have to set it before you add it as a child otherwise the room area's think you are exiting them
	rangedProjectile.global_position = restingPos.global_position
	world.add_child(rangedProjectile)
	rangedProjectile.fire(restingPos.global_position, self.global_rotation)
	
func startAOEAttack(targetGlobalPos : Vector2, sourceStr := 0):
	var areaOfEffect = AreaOfEffectScene.instance()
	areaOfEffect.init(weaponStats, source, sourceStr, weaponStats.aoeLifetime, weaponStats.aoeNumberOfTicks)
	
	var world = get_tree().current_scene
	# Have to set it before you add it as a child otherwise the room area's think you are exiting them
	areaOfEffect.global_position = targetGlobalPos
	world.get_node("YSort").add_child(areaOfEffect)
	
	# TODO: Possibly pass in a rotation if it is a directional aoe (like a cone)
	areaOfEffect.fire(self.global_position, targetGlobalPos, self.global_rotation)

func setWeapon(weaponStats : WeaponStats):
	self.weaponStats = weaponStats
	weaponHitbox.setWeapon(weaponStats)
	weaponSprite.texture = weaponStats.texture
	tween.remove_all()
	backTween.remove_all()
	weaponSprite.position = Vector2.ZERO
	
	if weaponStats.weaponType == WeaponStats.WeaponType.MELEE or weaponStats.weaponType == WeaponStats.WeaponType.SWORD:
		restingPos.position = meleeRestingCoord
		weaponSprite.rotation = restingRotation
		returnRot = weaponSprite.rotation
		swordAnimDist = weaponCollision.position - restingPos.position
		swipe.frame = 0
		
		swipe.position = weaponCollision.position
		# Ratios I found from doing testing with OG sprite
		swipe.scale.x = .6 * (weaponStats.radius)/10
		swipe.scale.y = 1.5 * (weaponStats.length/2 + weaponStats.radius)/10
	elif weaponStats.weaponType == WeaponStats.WeaponType.HEAVY:
		restingPos.position = meleeRestingCoord + Vector2(-15, 15)
		weaponSprite.rotation = deg2rad(-165)
		returnRot = deg2rad(-165)
		swordAnimDist = weaponCollision.position - restingPos.position
		swipe.frame = 0
		
		swipe.position = weaponCollision.position
		# Ratios I found from doing testing with OG sprite
		swipe.scale.x = .6 * (weaponStats.radius)/10
		swipe.scale.y = 1.5 * (weaponStats.length/2 + weaponStats.radius)/10
	elif weaponStats.weaponType == WeaponStats.WeaponType.SPEAR:
		restingPos.position = Vector2(weaponStats.length/8, 0)
		weaponSprite.position = restingPos.position
		weaponSprite.rotation = deg2rad(45)
		returnRot = weaponSprite.rotation
		swordAnimDist = weaponCollision.position - restingPos.position
		swipe.frame = 0
		
		swipe.position = weaponCollision.position
		# Ratios I found from doing testing with OG sprite
		swipe.scale.x = .6 * (weaponStats.radius)/10
		swipe.scale.y = 1.5 * (weaponStats.length/2 + weaponStats.radius)/10
	elif weaponStats.weaponType == WeaponStats.WeaponType.RANGED:
		restingPos.set_deferred("position", Vector2(15, 0))
		weaponSprite.set_deferred("rotation", deg2rad(45))
		weaponSprite.hframes = 6
	else:
		restingPos.set_deferred("position", Vector2(10, 0))
		weaponSprite.set_deferred("rotation", deg2rad(-45))
		swordAnimDist = weaponCollision.position - restingPos.position
		
	if not weaponStats.weaponType == WeaponStats.WeaponType.RANGED:
		weaponSprite.hframes = 1

# TODO: Can set tween delay rather than making multiple tweens
func _on_WeaponTween_tween_completed():
		
	self.show_behind_parent = not self.show_behind_parent
	if weaponStats.weaponType == WeaponStats.WeaponType.SPEAR:
		backTween.interpolate_property(weaponSprite, "position", weaponSprite.position, Vector2(weaponStats.length/2, 0), self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

		# Add the .007 so if player is spam clicking it feels more fluid/no stop on swing
		backTween.interpolate_property(weaponSprite, "position", Vector2(weaponStats.length/2, 0), Vector2.ZERO, attackTimer.time_left + .007, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, self.tweenLength)
	
	else:
		backTween.interpolate_property(weaponSprite, "position", weaponSprite.position, Vector2(-20, 5), self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		backTween.interpolate_property(weaponSprite, "rotation", weaponSprite.rotation, restingRotation - deg2rad(50), self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN)

		# Add the .007 so if player is spam clicking it feels more fluid/no stop on swing
		backTween.interpolate_property(weaponSprite, "position", Vector2(-20, 5), Vector2.ZERO, attackTimer.time_left + .007, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, self.tweenLength)
		backTween.interpolate_property(weaponSprite, "rotation", restingRotation - deg2rad(50), returnRot, attackTimer.time_left + .007, Tween.TRANS_LINEAR, Tween.EASE_IN, self.tweenLength)
	
	backTween.start()

