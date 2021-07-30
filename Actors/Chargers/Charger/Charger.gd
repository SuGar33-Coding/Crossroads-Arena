class_name Charger extends Fighter

const ChargeDmgSpeedFrac = 0.25

export var maxChargeRange: int = 125
export var minChargeRange: int = 20
export var chargeTimeMax: float = 15
export var chargeTimeMin: float = 8
export var chargeTimeout: float = 4 # Timeout after which a charge is forced to stop

var dirtSpreadFX = preload("res://FX/DirtSpread.tscn")

var charging := false setget setCharging
var chargeDirection := Vector2.ZERO
var chargeTimer: Timer
var chargeTimeoutTimer: Timer

onready var baseMaxSpeed := self.MaxSpeed
onready var baseAcceleration := self.Acceleration

func _ready():
	chargeTimer = Timer.new()
	chargeTimer.one_shot = true
	add_child(chargeTimer)
	
	chargeTimeoutTimer = Timer.new()
	chargeTimeoutTimer.one_shot = true
	add_child(chargeTimeoutTimer)

func _physics_process(_delta):
	if charging:
		# check stop conditions
		if get_slide_count() > 0:
			# hit something
			self.charging = false
		elif chargeTimeoutTimer.is_stopped():
			# charged for too long
			self.charging = false
		
		# determine when to activate hitbox
		if velocity.length() > (MaxSpeed * ChargeDmgSpeedFrac):
			attackPivot.weaponCollision.disabled = false

func willAttack() -> bool:
	if not charging:
		if canCharge():
			self.charging = true
			return true
		else:
			return .willAttack()
	else:
		return false

func switchToAttack():
	if charging:
		state = State.ATTACK
		animationPlayer.playback_speed = 1
		animationPlayer.play("ChargeWindup")
		var animLength = animationPlayer.current_animation_length

		chargeTimeoutTimer.start(chargeTimeout)
		chargeTimer.start(rand_range(chargeTimeMin, chargeTimeMax) + animLength)
	elif attackTimer.is_stopped():
		.switchToAttack()

func willStun() -> bool:
	if charging:
		return false
	else:
		return .willStun()

func switchToStun():
	.switchToStun()
	animationPlayer.playback_speed = 1
	animationPlayer.play('Stunned')

func willFlipLeft():
	if charging:
		return false
	else:
		 return .willFlipLeft()

func willFlipRight():
	if charging:
		return false
	else:
		 return .willFlipRight()

func canCharge():
	if self.isTargetVisible and is_instance_valid(target):
		var distanceToTarget = self.global_position.distance_to(target.global_position)

		return chargeTimer.is_stopped() and distanceToTarget <= maxChargeRange and distanceToTarget >= minChargeRange
	else:
		return false

func lookAtTarget():
	# always look in the direction you're charging
	if not charging:
		return .lookAtTarget()

func setCharging(value: bool):
	charging = value
	if charging:
		# Adjust movement for charge
		self.velocity = Vector2.ZERO
		self.MaxSpeed = baseMaxSpeed * 2.5
		self.Acceleration = baseAcceleration * 0.1
		
		setChargeDirection()
		(attackPivot as ChargerAttackPivot).startCharge(chargeDirection)
	else:
		# Reset movement
		self.Acceleration = baseAcceleration
		if get_slide_count() > 0:
			# hit something
			var collision := get_slide_collision(0)
			var travelDir := collision.travel.normalized()
			var recoilDir := (travelDir * -1).rotated(deg2rad(rand_range(-15, 15)))
			self.velocity = recoilDir * self.velocity.length() * 1.5
			
			var dirtSpreadFXNode: Particles2D = dirtSpreadFX.instance()
			add_child(dirtSpreadFXNode)
			dirtSpreadFXNode.emitting = true
		else:
			self.velocity = Vector2.ZERO
		self.MaxSpeed = baseMaxSpeed
		
		# Reset weapon
		(attackPivot as ChargerAttackPivot).stopCharge()
		
		# always stun
		self.switchToStun()

func setChargeDirection():
	if target != null:
		chargeDirection = self.global_position.direction_to(target.global_position)
		
func playMovement():
	if charging:
		# Goes from 1 to max based on current velocity's fraction of max speed
		var maxPlaybackSpeed = 2.5
		var playbackSpeed = ((self.velocity.length() / self.MaxSpeed) * (maxPlaybackSpeed - 1)) + 1
		animationPlayer.playback_speed = playbackSpeed
		animationPlayer.play("Charge")
	else:
		.playMovement()
