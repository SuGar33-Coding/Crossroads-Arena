extends NPC

var weaponStats : WeaponStats

onready var detectionZone := $DetectionZone
onready var attackPivot := $AttackPivot
onready var weaponHitbox := $AttackPivot/WeaponHitbox
onready var animationPlayer := $AnimationPlayer
onready var attackTimer := $AttackTimer
onready var moveDirTimer := $MoveDirTimer

var sinX = rand_range(0, TAU)
var noise := OpenSimplexNoise.new()
var noiseY = 1
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
	
	
func lookAtTarget():
	attackPivot.lookAtTarget(detectionZone.target.position)

func switchToChase() -> void:
	.switchToChase()
	target = detectionZone.target
	
func switchToAttack():
	if attackTimer.is_stopped():
		.switchToAttack()
		animationPlayer.playback_speed = 1
		animationPlayer.play("MeleeAttack")
		attackTimer.start(1)

func willIdle() -> bool:
	return !detectionZone.hasTarget()

func willChase() -> bool:
	return detectionZone.hasTarget()

func willAttack() -> bool:
	var distanceToTarget = (self.position - detectionZone.target.position).length()
	return distanceToTarget <= (weaponStats.length + weaponStats.radius) * 2
	
func flipLeft():
	sprite.flip_h = true
	attackPivot.scale.y = -1
	
func flipRight():
	sprite.flip_h = false
	attackPivot.scale.y = 1

func _hurtbox_area_entered(area : WeaponHitbox):
	._hurtbox_area_entered(area)
	# Only play damaged if we're not dead
	if(stats.health >= 1):
		animationPlayer.stop(true)
		animationPlayer.playback_speed = 1
		animationPlayer.play("Damaged")

# Handle actor's weapon being parried by player
func _weapon_parried(area : WeaponHitbox):
	state = State.STUN
	knockback = area.getKnockbackVector(self.global_position)
	animationPlayer.stop(true)
	animationPlayer.playback_speed = .3
	animationPlayer.play("Damaged")

func _change_direction():
	moveDir *= -1
	moveDirTimer.start(rand_range(1, moveDirMaxLen))


