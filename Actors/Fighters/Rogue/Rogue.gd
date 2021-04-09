extends Fighter

var dashCloudFx = preload("res://FX/DashCloud.tscn")

export(int) var maxLeapRange = 125
export(int) var minLeapRange = 40
export(float) var leapTimeMax = 9
export(float) var leapTimeMin = 5
export(float) var LeapAcceleration = 10000
export(float) var BaseLeapSpeed = 600 
export(float) var overDashAmount = 30
export(float) var stopRange = 10

var collisionChecker = preload("res://Actors/Zones/CollisionCheck.tscn")
var groundPoundFx = preload("res://FX/GroundPoundFx.tscn")
var leaping : bool = false setget setLeaping
var LeapSpeed : float = 5000
var poundRange : float
var leapTarget : Vector2 = Vector2.ZERO

onready var leapTimer := $LeapTimer

# TODO add specific leap target
func _physics_process(_delta):
	if leaping and target and state == State.CHASE:
		if self.global_position.distance_to(leapTarget) < stopRange:
			# If we want them to have to wind up first, just play wind up here
			animationPlayer.play("MeleeAttack")
			stopLeapSpeed()

# When in range I want to stop and charge up :: Use attack state to stop us
# Then I want to reenter chase to start moving toward target, but prevent reenteringa ttack state :: use boolean
# When I land I want to set a timer between leaps and allow to enter normal attack state
func switchToAttack():
	if leaping:
		state = State.ATTACK
		animationPlayer.play("Dash")
		var animLength = animationPlayer.current_animation_length
		LeapSpeed = BaseLeapSpeed
		leapTimer.start(rand_range(leapTimeMin, leapTimeMax)+animLength)
		#self.switchToChase()
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
	
#func playGroundPound():
	#animationPlayer.play("GroundPound")
	
func setLeapTargetPos():
	if target:
		leapTarget = target.global_position
		if self.global_position.distance_to(leapTarget) > maxLeapRange:
			leapTarget = self.global_position + self.global_position.direction_to(leapTarget) * maxLeapRange
	else:
		leapTarget = self.global_position
	
	leapTarget = leapTarget + self.global_position.direction_to(leapTarget) * overDashAmount
	
func getTargetPos():
	if leaping:
		return leapTarget
	else:
		return target.global_position

func setLeaping(value : bool):
	leaping = value
	
func spawnDashFx():
	var dashCloudFxInstance: Particles2D = dashCloudFx.instance()
	dashCloudFxInstance.global_position = Vector2(self.global_position.x, self.global_position.y + 12)
	dashCloudFxInstance.z_index = -1
	dashCloudFxInstance.emitting = true
	get_tree().current_scene.add_child(dashCloudFxInstance)

func canLeap():
	if self.isTargetVisible:
		var distanceToTarget = self.global_position.distance_to(target.global_position)
		return leapTimer.is_stopped() and distanceToTarget <= maxLeapRange and distanceToTarget >= minLeapRange
	else:
		return false

func _hurtbox_area_entered(area: Hitbox):
	._hurtbox_area_entered(area)
	leaping = false
