extends NPC

onready var detectionZone := $DetectionZone
onready var animationPlayer := $AnimationPlayer

func _ready():
	animationPlayer.play("Idle")
	
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
	
func flipRight():
	sprite.flip_h = false
	
func switchToChase() -> void:
	.switchToChase()
	animationPlayer.play("Idle")
	target = detectionZone.target
	
func willIdle() -> bool:
	return !detectionZone.hasTarget()

func willChase() -> bool:
	return detectionZone.hasTarget()

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

func _hurtbox_area_entered(area: Hitbox):
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
