extends NPC

onready var detectionZone := $DetectionZone
onready var attackPivot := $AttackPivot
onready var meleeHitbox := $AttackPivot/WeaponHitbox/WeaponCollision
onready var animationPlayer := $AnimationPlayer


# TODO: move this to a parent script


func lookAtTarget():
	attackPivot.lookAtTarget(detectionZone.target.position)

# TODO: These will all be overridden in an inhereted scirpt

func switchToChase():
	.switchToChase()
	target = detectionZone.target

func willIdle() -> bool:
	return !detectionZone.hasTarget()

func willChase() -> bool:
	return detectionZone.hasTarget()

func willAttack() -> bool:
	var distanceToTarget = (self.position - detectionZone.target.position).length()
	var capsuleShape: CapsuleShape2D = meleeHitbox.shape
	return distanceToTarget <= (capsuleShape.height + capsuleShape.radius) * 2
	
func flipLeft():
	sprite.flip_h = true
	attackPivot.scale.y = -1
	
func flipRight():
	sprite.flip_h = false
	attackPivot.scale.y = 1

func switchToAttack():
	.switchToAttack()
	animationPlayer.play("MeleeAttack")



