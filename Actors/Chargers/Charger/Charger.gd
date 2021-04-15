class_name Charger extends Fighter

export var maxChargeRange: int = 125
export var minChargeRange: int = 20
export var chargeTimeMax: float = 9
export var chargeTimeMin: float = 5

var charging := false
var chargeDirection := Vector2.ZERO

onready var weaponCollision := $AttackPivot/WeaponHitbox/WeaponCollision
onready var chargeTimer := Timer.new()
onready var baseMaxSpeed := self.MaxSpeed
onready var baseAcceleration := self.Acceleration

func switchToAttack():
	if charging:
		self.velocity = Vector2.ZERO
		self.MaxSpeed = baseMaxSpeed * 2
		self.Acceleration = baseAcceleration * 2
		
		# TODO: replace this with some other method of hit detection while charging
		weaponCollision.disabled = false
		
		state = State.ATTACK
		animationPlayer.play("Charge")
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
