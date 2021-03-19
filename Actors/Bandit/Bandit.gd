extends NPC

var weaponStats : WeaponStats

onready var detectionZone := $DetectionZone
onready var attackPivot := $AttackPivot
onready var weaponHitbox := $AttackPivot/WeaponHitbox
onready var animationPlayer := $AnimationPlayer

func _ready():
	weaponStats = weaponHitbox.weaponStats
	weaponHitbox.connect("parried", self, "_weapon_parried")
	
	
func lookAtTarget():
	attackPivot.lookAtTarget(detectionZone.target.position)

func switchToChase():
	.switchToChase()
	target = detectionZone.target

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
	
	
func switchToAttack():
	.switchToAttack()
	animationPlayer.playback_speed = 1
	animationPlayer.play("MeleeAttack")



