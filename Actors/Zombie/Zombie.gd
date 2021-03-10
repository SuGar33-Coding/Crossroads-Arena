extends KinematicBody2D

export var ACCELERATION = 600
export var MAX_SPEED = 75
export var FRICTION = 850

enum {
	IDLE,
	WANDER,
	CHASE,
	DYING
}

var state = IDLE
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var stats = $Stats
onready var detectionZone = $DetectionZone
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_target()
			
		CHASE:
			var target = detectionZone.target
			if(target != null):
				var direction = global_position.direction_to(target.global_position)
				self.look_at(self.global_position + direction) 
				self.rotate(deg2rad(90))
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
	
	velocity = move_and_slide(velocity)

func _on_Stats_noHealth():
	state = DYING
	animationPlayer.play("Death")
	

func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.getKnockbackVector(self.global_position)

func seek_target():
	if detectionZone.can_see_target():
		state = CHASE
