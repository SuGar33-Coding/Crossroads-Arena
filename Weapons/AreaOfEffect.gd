# The AreaOfEffect class functions a lot like a ranged projectile
# Except that it should be given a position away from the user and have 
# little to no velocity.  An AOE effect does not die on first contact
# like a projectile does
class_name AreaOfEffect extends KinematicBody2D

# Accuracy timing thresholds
const THRESHOLD = 10

# number of damage ticks
var totalTicks := 2
var numTicks := 0
var lifetime := 1.0
var fromPlayer : bool = false
var speed : float
var velocity := Vector2.ZERO
var weaponStats : WeaponInstance
var source
var userStr : int
var HitEffect = preload("res://FX/HitEffect.tscn")
var aoeEffect : AoeFX
var targetPosition := Vector2.ZERO
# Whether you need to check the logic in physics process
var checkPosition := false
var fired := false

onready var collision : CollisionShape2D = $Collision
onready var offsetNode : Node2D = $OffsetNode
onready var weaponHitbox : WeaponHitbox = $OffsetNode/WeaponHitbox
onready var sustainHitbox : SustainHitbox = $OffsetNode/SustainHitbox
onready var tickTimer : Timer = $TickTimer
onready var particles : Particles2D = $OffsetNode/Particles2D
onready var sprite : Sprite = $Sprite
onready var animationPlayer : AnimationPlayer = $AnimationPlayer
onready var crosshair : Sprite = $CrosshairSprite

func init(weaponStats: WeaponInstance, source, sourceStr: int, lifetime: float, numberOfTicks: int):
	self.weaponStats = weaponStats
	
	self.totalTicks = numberOfTicks
	self.lifetime = lifetime
	self.source = source
	# AOE stuff scales less with strength
	self.userStr = sourceStr * 1/3
	
	self.fromPlayer = (source.name == "Player")
		
func _ready():
	weaponHitbox.setWeapon(weaponStats)
	weaponHitbox.setSource(self, userStr)

	self.weaponHitbox.set_collision_mask_bit(4, true)
	self.weaponHitbox.set_collision_mask_bit(5, false)
	self.sustainHitbox.set_collision_mask_bit(4, true)
	self.sustainHitbox.set_collision_mask_bit(5, false)
	
	sustainHitbox.collision.disabled = true
	
	# Crosshair radius is 20, so scale that to aoe
	crosshair.scale.x = .33333
	crosshair.scale.y = .33333
	crosshair.visible = false
	
	tickTimer.connect("timeout", self, "_tick_timeout")
	
	speed = weaponStats.projectileSpeed
	
	# TODO: Reposition so that YSORT position is much lower
	aoeEffect = weaponStats.aoeEffect

	if (weaponStats.aoeType == WeaponStats.AoeType.SUSTAIN or weaponStats.aoeType == WeaponStats.AoeType.IMPACT_AND_SUSTAIN):
		particles.emitting = false
		particles.process_material = aoeEffect.effectMaterial
		particles.lifetime = aoeEffect.particleLifetime
		particles.amount = aoeEffect.numParticles
		particles.speed_scale = aoeEffect.speedScale

		sustainHitbox.effectResources = weaponHitbox.effectResources
		var sustainShape = sustainHitbox.collision.shape as CapsuleShape2D
		sustainShape.height = weaponStats.sustainLength
		sustainShape.radius = weaponStats.sustainRadius
	
func _physics_process(delta):
	var move = move_and_collide(velocity * delta)
	
	if( (not aoeEffect.aoeType == AoeFX.Type.LOBBED and move != null) or (checkPosition and targetPosition.distance_to(self.global_position) < THRESHOLD)):
		checkPosition = false
		startAoe()
		velocity = Vector2.ZERO
	
	if(fired):
		crosshair.global_position = targetPosition

# TODO: Change crosshair to be its own scene rather than a child of aoe
func fire(userPosition : Vector2, targetPosition : Vector2, startingRotation := 0.0):
	
	weaponHitbox.collision.set_deferred("disabled", true)
	
	weaponHitbox.global_rotation = startingRotation
	
	crosshair.global_position = targetPosition
	crosshair.visible = true
	
	fired = true
	
	self.targetPosition = targetPosition
	# TODO: Temporarily if it is from player then change its layer mask, will eventually do this with groups instead
	if fromPlayer:
		self.weaponHitbox.set_collision_mask_bit(4, false)
		self.weaponHitbox.set_collision_mask_bit(5, true)
		self.sustainHitbox.set_collision_mask_bit(4, false)
		self.sustainHitbox.set_collision_mask_bit(5, true)
	match aoeEffect.aoeType:
		AoeFX.Type.PLACE:
			# Aoe spawns on given point
			self.global_position = targetPosition
			particles.emitting = true
			
			self.startAoe()
			
		AoeFX.Type.RANGED:
			# Projectile originating from the user that bursts into an aoe
			self.global_position = userPosition
			velocity =  Vector2(1,0).rotated(startingRotation) * speed
			
			checkPosition = true
			sprite.texture = weaponStats.projectileTexture
			sprite.global_rotation = startingRotation
			sprite.set_deferred("visible", true)

		AoeFX.Type.LOBBED:
			# Has an arched projectile originating from the user that bursts into an aoe
			self.global_position = userPosition
			velocity =  Vector2(1,0).rotated(startingRotation) * (userPosition.distance_to(targetPosition)/aoeEffect.chargeupTime)
			
			sprite.texture = weaponStats.projectileTexture
			sprite.global_rotation = startingRotation
			sprite.set_deferred("visible", true)
			
			# Use animation player to have the projectile make an arch
			animationPlayer.playback_speed = 1/aoeEffect.chargeupTime
			animationPlayer.play("Lob")
			
		AoeFX.Type.MOVING:
			# Aoe spawns on given point and continues moving forward damagin in its path
			self.global_position = targetPosition
			velocity =  Vector2(1,0).rotated(startingRotation) * speed
			
			self.startAoe()
			
	# May need to use this if we want aoe to be able to move (like a tornado
	"""if(weaponStats.aoeAngle >= 0):
		self.global_rotation = startingRotation + weaponStats.aoeAngle
	else:
		self.global_rotation = 0"""
	
# Starts the particle and damaging affects of the aoe
func startAoe():
	collision.disabled = true
	sprite.set_deferred("visible", false)
	crosshair.visible = false

	# We want ysort to be better so move all of the visuals up but the root node down
	self.global_position.y += aoeEffect.ysortOffset
	offsetNode.global_position.y -= aoeEffect.ysortOffset

	match weaponStats.aoeType:
		WeaponStats.AoeType.IMPACT:
			yield(startImpact(), "completed")
			# clean up here instad of via sustain
			stopAoe()

		WeaponStats.AoeType.SUSTAIN:
			startSustain()

		WeaponStats.AoeType.IMPACT_AND_SUSTAIN:
			yield(startImpact(), "completed")
			startSustain()

func startImpact():
	weaponHitbox.collision.set_deferred("disabled", false)
	yield(get_tree().create_timer(0.1), "timeout")
	weaponHitbox.collision.set_deferred("disabled", true)

func startSustain():
	particles.set_deferred("emitting", true)
	if(weaponStats.instantApplySustain):
		_tick_timeout()
		tickTimer.start(lifetime / totalTicks-1)
	else:
		tickTimer.start(lifetime / totalTicks)
	
func stopMovement():
	velocity = Vector2.ZERO
	
func stopAoe():
	tickTimer.stop()
	if (weaponStats.aoeType == WeaponStats.AoeType.SUSTAIN || weaponStats.aoeType == WeaponStats.AoeType.IMPACT_AND_SUSTAIN):
		# wait for particles to finish before killing
		particles.set_deferred("emitting", false)
		yield(get_tree().create_timer(particles.lifetime), "timeout")
	queue_free()

# Ticker for reapplying effects
func _tick_timeout():
	# TODO: this is bad, make this better (faster ticks? maybe always have the sustain on?)
	sustainHitbox.collision.set_deferred("disabled", false)
	yield(get_tree().create_timer(0.1), "timeout")
	sustainHitbox.collision.set_deferred("disabled", true)
	numTicks += 1
	if numTicks >= totalTicks:
		stopAoe()
