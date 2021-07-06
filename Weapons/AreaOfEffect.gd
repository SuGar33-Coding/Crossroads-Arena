# The AreaOfEffect class functions a lot like a ranged projectile
# Except that it should be given a position away from the user and have 
# little to no velocity.  An AOE effect does not die on first contact
# like a projectile does
extends KinematicBody2D

class_name AreaOfEffect

# Accuracy timing thresholds
const CRIT = 0.1
const HALF_CRIT = 0.2
const NORMAL = 0.5
const REDUCED = 0.75

# number of damage ticks
var totalTicks := 2
var numTicks := 0
var lifetime := 1.0
var fromPlayer : bool = false
var speed
var velocity := Vector2.ZERO
var weaponStats : WeaponStats
var source
var userStr : int
var HitEffect = preload("res://FX/HitEffect.tscn")

onready var weaponHitbox := $WeaponHitbox
onready var sprite := $Sprite
onready var collision := $CollisionShape2D
onready var tickTimer := $TickTimer
onready var hurtTimer := $HurtTimer

func init(weaponStats: WeaponStats, source, sourceStr: int, lifetime: float, numberOfTicks: int):
	self.weaponStats = weaponStats
	self.source = source
	self.totalTicks = numberOfTicks
	self.lifetime = lifetime
	
	# AOE stuff scales less with strength
	self.userStr = sourceStr * 1/3
	
	self.fromPlayer = (source.name == "Player")

func _ready():
	weaponHitbox.setWeapon(weaponStats)
	weaponHitbox.setSource(source, userStr)
	
	tickTimer.connect("timeout", self, "_tick_timeout")
	hurtTimer.connect("timeout", self, "_hurt_timeout")
	
	speed = weaponStats.projectileSpeed
	
	sprite.texture = weaponStats.projectileTexture
	
func _physics_process(_delta):
	move_and_slide(velocity)

func fire(startingPosition : Vector2, startingRotation := 0.0):
	
	weaponHitbox.collision.set_deferred("disabled", true)
	# TODO: Temporarily if it is from player then change its layer mask, will eventually do this with groups instead
	if fromPlayer:
		self.weaponHitbox.set_collision_mask_bit(4, false)
		self.weaponHitbox.set_collision_mask_bit(5, true)
	self.global_position = startingPosition
	if(weaponStats.aoeAngle >= 0):
		self.global_rotation = startingRotation + weaponStats.aoeAngle
	else:
		self.global_rotation = 0
	velocity =  Vector2(1,0).rotated(self.global_rotation) * speed
	
	tickTimer.start(lifetime / totalTicks)
	
func killSelf():
	queue_free()

# Tick Timer loops automatically, turn off and on collision box every tick
# in order to redo damage
func _tick_timeout():
	weaponHitbox.collision.set_deferred("disabled", false)
	# Turn on hitbox for .1 seconds to do damage and turn off otherwise
	hurtTimer.start(.1)
	

func _hurt_timeout():
	weaponHitbox.collision.set_deferred("disabled", true)
	numTicks += 1
	if numTicks >= totalTicks:
		queue_free()
