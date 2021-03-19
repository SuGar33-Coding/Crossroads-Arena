extends KinematicBody2D

class_name NPC

export var movementResource: Resource
export var MaxSpeed: float = 175
export var Acceleration: float = 1000
export var Friction: float = 1000

enum State {
	IDLE,
	CHASE,
	ATTACK,
	STUN
}

var state = State.IDLE
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var target = null

onready var movement: Movement = movementResource
onready var sprite := $Sprite
onready var stats := $Stats
onready var hurtbox := $Hurtbox

func _ready():
	hurtbox.connect("area_entered", self, "_hurtbox_area_entered")
	stats.connect("noHealth", self, "_stats_no_health")
	
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, Friction * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		State.IDLE:
			velocity = movement.getIdleVelocity(self, delta)
			if willChase():
				switchToChase()
		State.CHASE:
			if willIdle():
				switchToIdle()
			else:
				lookAtTarget()
				if willAttack():
					switchToAttack()
				velocity = movement.getMovementVelocity(self, target, delta)
		State.ATTACK:
			velocity = movement.getIdleVelocity(self, delta)
		State.STUN:
			velocity = movement.getIdleVelocity(self, delta)
	
	if velocity.x < 0:
		flipLeft()
		
	elif velocity.x > 0:
		flipRight()
		
	velocity = move_and_slide(velocity)
	
func lookAtTarget():
	pass
	
func willIdle() -> bool:
	return false
	
func willChase() -> bool:
	return false
	
func willAttack() -> bool:
	return false
	
func switchToIdle():
	self.state = State.IDLE
	
func switchToChase():
	self.state = State.CHASE
	
func switchToAttack():
	self.state = State.ATTACK
	
func flipLeft():
	pass
	
func flipRight():
	pass
	
func _hurtbox_area_entered(area : WeaponHitbox):
	state = State.STUN
	stats.health -= area.damage
	knockback = area.getKnockbackVector(self.global_position)

func _stats_no_health():
	queue_free()
