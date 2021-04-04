extends KinematicBody2D

class_name RangedProjectile

var fromPlayer : bool = false
var speed
var velocity := Vector2.ZERO
var weaponStats : WeaponStats
var source
var accuracy : float
var userStr : int
var HitEffect = preload("res://FX/HitEffect.tscn")

onready var weaponHitbox := $WeaponHitbox
onready var sprite := $Sprite
onready var collision := $CollisionShape2D

func init(weaponStats: WeaponStats, source, sourceStr: int, acc: float):
	self.weaponStats = weaponStats
	self.source = source
	self.accuracy = acc
	
	# Ranged stuff scales less with strength
	self.userStr = sourceStr * 3/4
	
	self.fromPlayer = (source.name == "Player")

func _ready():
	weaponHitbox.setWeapon(weaponStats)
	weaponHitbox.setSource(source, userStr)
	
	weaponHitbox.scaleDamage(1/accuracy)
	
	speed = weaponStats.projectileSpeed
	
	sprite.texture = weaponStats.projectileTexture
	
	weaponHitbox.connect("area_entered", self, "_area_entered")
	$WeaponHitbox/ParryHitbox.connect("area_entered", self, "_area_entered")
	
func _physics_process(delta):
	var move = move_and_collide(velocity * delta)
	if move != null:
		# Kills if runs into a wall
		self.killSelf()

func fire(startingPosition : Vector2, startingRotation : float):
	
	# TODO: Temporarily if it is from player then change its layer mask, will eventually do this with groups instead
	if fromPlayer:
		self.weaponHitbox.set_collision_mask_bit(4, false)
		self.weaponHitbox.set_collision_mask_bit(5, true)
	self.global_position = startingPosition
	self.global_rotation = startingRotation
	velocity =  Vector2(1,0).rotated(self.global_rotation) * speed
	
func killSelf():
	var hitEffect = HitEffect.instance()
	hitEffect.global_position = global_position
	hitEffect.init(global_position + velocity.normalized() * self.collision.shape.height)
	
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	queue_free()

func _area_entered(area):
	queue_free()
