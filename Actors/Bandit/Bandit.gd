extends KinematicBody2D

export var movementResource: Resource
export var MaxSpeed: float = 175
export var Acceleration: float = 1000
export var Friction: float = 1000

var state = State.IDLE
var velocity = Vector2.ZERO

onready var movement: Movement = movementResource
onready var detectionZone := $DetectionZone
onready var attackPivot := $AttackPivot
onready var meleeHitbox := $AttackPivot/Hitbox/HitboxCollision
onready var animationPlayer := $AnimationPlayer

enum State {
	IDLE,
	CHASE,
	ATTACK
}

# TODO: move this to a parent script
func _physics_process(delta):
	match state:
		State.IDLE:
			velocity = movement.getIdleVelocity(self, delta)
			if willChase():
				switchToChase()
		State.CHASE:
			if !willIdle():
				lookAtTarget()
				if willAttack():
					switchToAttack()
				velocity = movement.getMovementVelocity(self, detectionZone.target, delta)
			else:
				switchToIdle()
		State.ATTACK:
			velocity = movement.getIdleVelocity(self, delta)
			
	velocity = move_and_slide(velocity)

func lookAtTarget():
	attackPivot.lookAtTarget(detectionZone.target.position)

# TODO: These will all be overridden in an inhereted scirpt

func willIdle() -> bool:
	return !detectionZone.hasTarget()
	
func switchToIdle():
	self.state = State.IDLE

func willChase() -> bool:
	return detectionZone.hasTarget()

func switchToChase():
	self.state = State.CHASE

func willAttack() -> bool:
	var distanceToTarget = (self.position - detectionZone.target.position).length()
	var capsuleShape: CapsuleShape2D = meleeHitbox.shape
	return distanceToTarget <= (capsuleShape.height + capsuleShape.radius) * 2

func switchToAttack():
	self.state = State.ATTACK
	animationPlayer.play("MeleeAttack")
	#attackPivot.startAttack()

