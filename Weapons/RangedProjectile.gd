extends KinematicBody2D

class_name RangedProjectile

var fromPlayer : bool = false
var speed
var velocity := Vector2.ZERO
var weaponStats : WeaponStats
var source
var userStr

onready var weaponHitbox := $WeaponHitbox
onready var sprite := $Sprite

func init(weaponStats: WeaponStats, source, sourceStr := 0):
	self.weaponStats = weaponStats
	self.source = source
	
	# Ranged stuff scales less with strength
	self.userStr = sourceStr / 2
	
	self.fromPlayer = (source.name == "Player")

func _ready():
	weaponHitbox.setWeapon(weaponStats)
	weaponHitbox.setSource(source, userStr)
	
	speed = weaponStats.projectileSpeed
	
	sprite.texture = weaponStats.projectileTexture
	
	weaponHitbox.connect("area_entered", self, "_area_entered")
	$WeaponHitbox/ParryHitbox.connect("area_entered", self, "_area_entered")
	
func _physics_process(delta):
	var move = move_and_collide(velocity * delta)
	if move != null:
		# Kills if runs into a wall
		self.queue_free()

func fire(startingPosition : Vector2, startingRotation : float):
	
	# TODO: Temporarily if it is from player then change its layer mask, will eventually do this with groups instead
	if fromPlayer:
		self.weaponHitbox.set_collision_mask_bit(4, false)
		self.weaponHitbox.set_collision_mask_bit(5, true)
	self.global_position = startingPosition
	self.global_rotation = startingRotation
	velocity =  Vector2(1,0).rotated(self.global_rotation) * speed

func _area_entered(_area):
	queue_free()
