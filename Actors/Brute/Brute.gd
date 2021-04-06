extends Fighter

export(int) var maxLeapRange = 200
export(int) var minLeapRange = 100
export(float) var leapTime = 3
export(float) var LeapAcceleration = 2000
export(float) var BaseLeapSpeed = 300 

var leapable : bool = false
var LeapSpeed : float = 5000

onready var leapTimer := $LeapTimer

func _ready():
	pass

func switchToChase() -> void:
	.switchToChase()
	var newTarget = detectionZone.getNewTarget()
	if newTarget != null:
		target = newTarget

# When in range I want to stop and charge up :: Use attack state to stop us
# Then I want to reenter chase to start moving toward target, but prevent reenteringa ttack state :: use boolean
# When I land I want to set a timer between leaps and allow to enter normal attack state
func switchToAttack():
	if leapable:
		state = State.ATTACK
		animationPlayer.play("Leap")
		var animLength = animationPlayer.current_animation_length
		LeapSpeed = BaseLeapSpeed
		leapTimer.start(leapTime+animLength)
	elif attackTimer.is_stopped():
		.switchToAttack()

func willAttack() -> bool:
	if not leapable:
		if canLeap():
			leapable = true
			return leapable
		else:
			leapable = false
			return .willAttack()
	else:
		return false

func slowLeapSpeed():
	LeapSpeed *= .1
	
func stopLeapSpeed():
	LeapSpeed = 0
	
func playGroundPound():
	animationPlayer.play("GroundPound")

func flipLeapable():
	leapable = not leapable

func canLeap():
	var distanceToTarget = self.position.distance_to(detectionZone.target.position)
	return leapTimer.is_stopped() and distanceToTarget <= maxLeapRange and distanceToTarget >= minLeapRange
