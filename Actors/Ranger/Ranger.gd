extends KinematicBody2D

export var ACCELERATION = 600
export var MAX_SPEED = 75
export var FRICTION = 850

const Arrow = preload("res://Weapons/Arrow.tscn")

enum {
	IDLE,
	WANDER,
	CHASE,
	FIRING,
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
onready var sprite = $Sprite
onready var firingRange = $FiringRange
onready var fireSpawnPosition = $FiringRange/SpawnPosition
onready var animationPlayer = $AnimationPlayer

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
			if(firingRange.targetInRange(target)):
				state = FIRING
				animationPlayer.play("Wind Up")
			elif(target != null):
				direction = global_position.direction_to(target.global_position)
				self.look_at(self.global_position + direction) 
				self.rotate(deg2rad(90))
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
		FIRING:
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

# TODO: somehow make arrow child of room you are in in order to pause it
func fireArrow() -> void:
	var arrow = Arrow.instance()
	var world = get_tree().current_scene
	world.add_child(arrow)
	arrow.fire(fireSpawnPosition.global_position, self.rotation + deg2rad(-90))

func _on_AnimationPlayer_animation_finished(anim_name):
	state = CHASE
