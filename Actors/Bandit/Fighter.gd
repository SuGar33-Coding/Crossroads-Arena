extends NPC

var weaponStats : WeaponStats

onready var detectionZone := $DetectionZone
onready var attackPivot := $AttackPivot
onready var weaponHitbox := $AttackPivot/WeaponHitbox
onready var animationPlayer := $AnimationPlayer
onready var attackTimer := $AttackPivot/AttackTimer
onready var moveDirTimer := $MoveDirTimer

var sinX = rand_range(0, TAU)
var noise := OpenSimplexNoise.new()
var noiseY = 1

# TODO: Possibly not necessary for the generic fighter class
var moveDir = 1
var moveDirMaxLen = 10

func _ready():
	randomize()
	weaponStats = weaponHitbox.weaponStats
	weaponHitbox.connect("parried", self, "_weapon_parried")
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20
	noise.persistence = .8
	moveDir = pow(-1, randi() % 2)
	moveDirTimer.start(rand_range(1, moveDirMaxLen))
	moveDirTimer.connect("timeout", self, "_change_direction")
	
	# Set everything to default values
	animationPlayer.play("Idle")
	
	
func lookAtTarget():
	attackPivot.lookAtTarget(detectionZone.target.position)

func switchToChase() -> void:
	.switchToChase()
	target = detectionZone.target
	
func switchToAttack():
	if attackTimer.is_stopped():
		.switchToAttack()
		animationPlayer.playback_speed = 1
		# TODO: Make this a more well defined ratio
		attackTimer.start(weaponStats.attackSpeed * 2)
		if weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
			animationPlayer.play("MeleeAttack")
		else:
			animationPlayer.play("RangedAttack")

func willIdle() -> bool:
	return !detectionZone.hasTarget()

func willChase() -> bool:
	return detectionZone.hasTarget()

func willAttack() -> bool:
	var distanceToTarget = self.position.distance_to(detectionZone.target.position)
	if weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
		return distanceToTarget <= (weaponStats.length + weaponStats.radius*2)
	else:
		return distanceToTarget <= weaponStats.projectileRange
	
func willFlipLeft():
	if state == State.CHASE:
		return global_position.x > target.global_position.x
	else:
		return .willFlipLeft()
		
func willFlipRight():
	if state == State.CHASE:
		return global_position.x < target.global_position.x
	else:
		return .willFlipRight()
	
func flipLeft():
	sprite.flip_h = true
	attackPivot.scale.y = -1
	
func flipRight():
	sprite.flip_h = false
	attackPivot.scale.y = 1
	
func findClosestAlly():
	var otherActors = get_parent().get_children()
	
	var allies = []
	for actor in otherActors:
		if(actor.is_in_group(movementGroup)):
			allies.append(actor)
	
	var minDist = 1000
	for ally in allies:
		var distance = (ally.global_position - self.global_position).length()
		if distance < minDist and ally != self:
			minDist = distance
			closestAlly = ally
		
	if minDist >= 1000:
		closestAlly = null

func _hurtbox_area_entered(area: WeaponHitbox):
	._hurtbox_area_entered(area)
	# Only play damaged if we're not dead
	if(stats.health >= 1):
		animationPlayer.stop(true)
		animationPlayer.playback_speed = 1
		animationPlayer.play("Damaged")
	else:
		# If you die add some extra knockback
		knockback = area.getKnockbackVector(self.global_position) * 1.5
		Friction = Friction * 1.8

# Handle actor's weapon being parried by player
func _weapon_parried(area : WeaponHitbox):
	state = State.STUN
	knockback = area.getKnockbackVector(self.global_position)
	animationPlayer.stop(true)
	animationPlayer.playback_speed = .3
	animationPlayer.play("Damaged")
	
func _stats_no_health():
	state = State.STUN
	animationPlayer.play("Death")

func _change_direction():
	moveDir *= -1
	moveDirTimer.start(rand_range(1, moveDirMaxLen))


