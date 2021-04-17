class_name Charger extends Fighter

export var maxChargeRange: int = 125
export var minChargeRange: int = 20
export var chargeTimeMax: float = 9
export var chargeTimeMin: float = 5

var charging := false
var chargeDirection := Vector2.ZERO

onready var chargeTimer := Timer.new()
onready var baseMaxSpeed := self.MaxSpeed
onready var baseAcceleration := self.Acceleration

func switchToAttack():
	if charging:
		# Adjust movement for charge
		self.velocity = Vector2.ZERO
		self.MaxSpeed = baseMaxSpeed * 2
		self.Acceleration = baseAcceleration * 2
		
		setChargeDirection()
		(attackPivot as ChargerAttackPivot).startCharge(chargeDirection)
		
		state = State.ATTACK
		animationPlayer.play("ChargeWindup")
		var animLength = animationPlayer.current_animation_length
		#BurstSpeed = BaseBurstSpeed
		chargeTimer.start(rand_range(chargeTimeMin, chargeTimeMax) + animLength)
	elif attackTimer.is_stopped():
		.switchToAttack()

func willAttack() -> bool:
	if not charging:
		if canCharge():
			charging = true
			return true
		else:
			charging = false
			return .willAttack()
	else:
		return false

func canCharge():
	if self.isTargetVisible:
		var distanceToTarget = self.global_position.distance_to(target.global_position)
		return chargeTimer.is_stopped() and distanceToTarget <= maxChargeRange and distanceToTarget >= minChargeRange
	else:
		return false

func lookAtTarget():
	# always look in the direction you're charging
	if not  charging:
		return .lookAtTarget()

func setChargeDirection():
	if target != null:
		chargeDirection = self.global_position.direction_to(target.global_position)
		
func playMovement():
	if charging:
		# Goes from 1 to max based on current velocity's fraction of max speed
		var maxPlaybackSpeed = 2.5
		print("frac: ", (self.velocity.length() / self.MaxSpeed))
		var playbackSpeed = ((self.velocity.length() / self.MaxSpeed) * (maxPlaybackSpeed - 1)) + 1
		animationPlayer.playback_speed = playbackSpeed
		animationPlayer.play("Charge")
	else:
		.playMovement()
