extends KinematicBody2D

export var ACCELERATION = 600
export var MAX_SPEED = 75
export var FRICTION = 1000

enum {
	IDLE,
	WANDER,
	CHASE,
	ATTACKING,
	DYING, 
	STUNNED
}

var state = IDLE
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var target = null
var direction = null

onready var stats = $Stats
onready var detectionZone = $DetectionZone
onready var meleeRange = $MeleeRange
onready var animationPlayer = $AnimationPlayer
onready var swipe = $Swipe

func _ready():
	swipe.frame = 0

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_target()
		STUNNED:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		CHASE:
			target = detectionZone.target
			if(meleeRange.targetInRange(target)):
				state = ATTACKING
				animationPlayer.play("MeleeAttack")
			elif(target != null):
				direction = global_position.direction_to(target.global_position)
				self.look_at(self.global_position + direction) 
				self.rotate(deg2rad(90))
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
		ATTACKING:
			if target != null:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				direction = global_position.direction_to(target.global_position)
				self.look_at(self.global_position + direction) 
				self.rotate(deg2rad(90))
	
	velocity = move_and_slide(velocity)

func _on_Stats_noHealth():
	state = DYING
	animationPlayer.play("Death")

func _on_hurtbox_area_entered(area):
	state = STUNNED
	stats.health -= area.damage
	knockback = area.getKnockbackVector(self.global_position)
	if(stats.health >= 1):
		animationPlayer.play("Damaged")
		#Only play damaged if we're not dead

func seek_target():
	if detectionZone.can_see_target():
		state = CHASE

func meleeAttack() -> void:
	swipe.set_deferred("flip_h", not swipe.flip_h)

func _on_AnimationPlayer_animation_finished(anim_name):
	state = CHASE
