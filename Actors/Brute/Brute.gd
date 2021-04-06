extends Fighter

export(int) var maxLeapRange = 250
export(int) var minLeapRange = 150
export(float) var leapTimeMax = 12
export(float) var leapTimeMin = 7
export(float) var LeapAcceleration = 12000
export(float) var BaseLeapSpeed = 600 

var groundPoundFx = preload("res://FX/GroundPoundFx.tscn")
var leaping : bool = false setget setLeaping
var LeapSpeed : float = 5000
var poundRange : float
var leapTarget : Vector2 = Vector2.ZERO

onready var leapTimer := $LeapTimer
onready var poundHitbox := $GroundPoundHitbox

func _ready():
	poundRange = poundHitbox.hitboxRadius + poundHitbox.hitboxHeight

# TODO add specific leap target
func _physics_process(_delta):
	if leaping and target and state == State.CHASE:
		if self.global_position.distance_to(target.global_position) < poundRange or self.global_position.distance_to(leapTarget) < poundRange:
			playGroundPound()

# When in range I want to stop and charge up :: Use attack state to stop us
# Then I want to reenter chase to start moving toward target, but prevent reenteringa ttack state :: use boolean
# When I land I want to set a timer between leaps and allow to enter normal attack state
func switchToAttack():
	if leaping:
		state = State.ATTACK
		animationPlayer.play("Leap")
		var animLength = animationPlayer.current_animation_length
		LeapSpeed = BaseLeapSpeed
		leapTimer.start(rand_range(leapTimeMin, leapTimeMax)+animLength)
	elif attackTimer.is_stopped():
		.switchToAttack()
	
func willAttack() -> bool:
	if not leaping:
		if canLeap():
			leaping = true
			return leaping
		else:
			leaping = false
			return .willAttack()
	else:
		return false

# TODO: Reimpliment stun shield while ground pounding/leaping
func willStun() -> bool:
	return not leaping

func slowLeapSpeed():
	LeapSpeed *= .1
	
func stopLeapSpeed():
	LeapSpeed = 0
	
func playGroundPound():
	animationPlayer.play("GroundPound")
	
func setLeapTargetPos():
	leapTarget = target.global_position
	
func getTargetPos():
	if leaping:
		return leapTarget
	else:
		return target.global_position

func setLeaping(value : bool):
	leaping = value
	
func spawnPoundFx():
	var poundFxInstance: Particles2D = groundPoundFx.instance()
	poundFxInstance.global_position = self.global_position #Vector2(self.global_position.x, self.global_position.y + 12)
	poundFxInstance.z_index = -1
	poundFxInstance.emitting = true
	get_tree().current_scene.add_child(poundFxInstance)

func canLeap():
	var distanceToTarget = self.global_position.distance_to(target.global_position)
	return leapTimer.is_stopped() and distanceToTarget <= maxLeapRange and distanceToTarget >= minLeapRange

func _hurtbox_area_entered(area: Hitbox):
	._hurtbox_area_entered(area)
	leaping = false
