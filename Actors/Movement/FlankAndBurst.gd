extends FlankAndPoke

class_name FlankAndBurst

# Smooth force used in steering while bursting
export var burstSmoothForce := 1.0

func getDirectToTarget(selfNode: KinematicBody2D, targetPos: Vector2):
	return selfNode.global_position.direction_to(targetPos)

func getMovementVelocity(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	
	if selfNode.bursting:
		var toTargetDir = getDirectToTarget(selfNode, targetPos)
		
		var desiredVelocity = toTargetDir * selfNode.BurstSpeed
	
		# Use steering to smooth our movement towards desired vector
		var steer = (desiredVelocity - selfNode.velocity)
		return selfNode.velocity.move_toward(selfNode.velocity + (steer * burstSmoothForce), selfNode.BurstAcceleration * delta)
	else:
		return .getMovementVelocity(selfNode, targetPos, delta)
	
	
	
