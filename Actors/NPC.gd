extends KinematicBody2D

class_name NPC

export var movementResource: Resource
export var MaxSpeed: float = 175
export var Acceleration: float = 1000
export var Friction: float = 1000
export var debug: bool = false
export var movementGroup: String = "NPC"

enum State {
	IDLE,
	CHASE,
	ATTACK,
	STUN
}

var state = State.IDLE
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var target: Node2D = null
var closestAlly : NPC = null

onready var movement: Movement = movementResource
onready var sprite := $Sprite
onready var stats : Stats = $Stats
onready var hurtbox := $Hurtbox

func _ready():
	self.add_to_group(movementGroup)
	hurtbox.connect("area_entered", self, "_hurtbox_area_entered")
	stats.connect("noHealth", self, "_stats_no_health")
	
func _physics_process(delta):
	if debug:
		update()
	knockback = knockback.move_toward(Vector2.ZERO, Friction * delta)
	knockback = move_and_slide(knockback)
	
	findClosestAlly()
	
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
				velocity = movement.getMovementVelocity(self, target.global_position, delta)
		State.ATTACK:
			velocity = movement.getIdleVelocity(self, delta)
		State.STUN:
			velocity = movement.getIdleVelocity(self, delta)
	
	if willFlipLeft():
		flipLeft()
		
	elif willFlipRight():
		flipRight()
		
	velocity = move_and_slide(velocity)

func _draw():
	if debug:
		# Draw some debug info
		var color = Color(1,0,0)
		draw_line(Vector2.ZERO, velocity, color)
		draw_line(velocity, velocity - velocity.rotated(deg2rad(-30)) * 0.1, color)
		draw_line(velocity, velocity - velocity.rotated(deg2rad(30)) * 0.1, color)
		
		var label = Label.new()
		var font = label.get_font("")
		draw_string(font, Vector2(-15,-25), State.keys()[state], Color(1,1,1))
	
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
	
func willFlipLeft() -> bool:
	return velocity.x < 0
	
func willFlipRight() -> bool:
	return velocity.x > 0
	
func flipLeft():
	pass
	
func flipRight():
	pass
	
func findClosestAlly():
	pass
	
func _hurtbox_area_entered(area : WeaponHitbox):
	if area.fromPlayer:
		PlayerStats.currentXP += min(stats.health, area.damage)
	state = State.STUN
	stats.health -= area.damage
	knockback = area.getKnockbackVector(self.global_position)

func _stats_no_health():
	queue_free()
