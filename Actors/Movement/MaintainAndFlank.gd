class_name MaintainAndFlank extends FlankAndPoke

func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	var movementDir: Vector2 = .getMovementDirection(selfNode, targetPos, delta)
	var distanceToTarget = targetPos.distance_to(selfNode.position)
	
	if distanceToTarget - radius <= 0:
		# If in range of target, reflect over tangent to radius
		var dirToTarget: Vector2 = selfNode.position.direction_to(targetPos)
		movementDir = movementDir.reflect(dirToTarget.rotated(-PI/2))
		
	return movementDir
