extends NPC

var weaponStats : WeaponStats

onready var detectionZone := $DetectionZone
onready var attackPivot := $AttackPivot
onready var meleeHitbox := $AttackPivot/WeaponHitbox
onready var animationPlayer := $AnimationPlayer

func _ready():
	weaponStats = meleeHitbox.weaponStats
	
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
		animationPlayer.play("Damaged")
	
func switchToAttack():
	.switchToAttack()
	animationPlayer.play("MeleeAttack")



