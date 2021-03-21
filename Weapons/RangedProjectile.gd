extends KinematicBody2D

class_name RangedProjectile


var speed
var velocity := Vector2.ZERO
var weaponStats : WeaponStats
var fromPlayer : bool

onready var weaponHitbox := $WeaponHitbox
onready var sprite := $Sprite

func init(weaponStats: WeaponStats, fromPlayer: bool = false):
	self.weaponStats = weaponStats
	self.fromPlayer = fromPlayer

func _ready():
	weaponHitbox.setWeapon(weaponStats)
	weaponHitbox.fromPlayer = fromPlayer
	
	speed = weaponStats.projectileSpeed
	
	sprite.texture = weaponStats.projectileTexture
	
	weaponHitbox.connect("area_entered", self, "_area_entered")
	$WeaponHitbox/ParryHitbox.connect("area_entered", self, "_area_entered")
	
func _physics_process(delta):
	var move = move_and_collide(velocity * delta)
	if move != null:
		# Kills if runs into a wall
		self.queue_free()

func fire(startingPosition : Vector2, startingRotation : float, fromPlayer := false):
	
	# TODO: Temporarily if it is from player then change its layer mask, will eventually do this with groups instead
	if fromPlayer:
		self.weaponHitbox.set_collision_mask_bit(4, false)
		self.weaponHitbox.set_collision_mask_bit(5, true)
	#playerArrow = fromPlayer
	self.global_position = startingPosition
	self.global_rotation = startingRotation
	velocity =  Vector2(1,0).rotated(self.global_rotation) * speed

func _area_entered(area):
	queue_free()
