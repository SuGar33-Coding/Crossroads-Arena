extends FlankAndPoke

class_name FlankAndLeap

# Smooth force used in steering while leaping
export var leapSmoothForce := 1.0

func getDirectToTarget(selfNode: KinematicBody2D, targetPos: Vector2):
	return selfNode.global_position.direction_to(targetPos)

func getMovementVelocity(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	
	if selfNode.leapable:
		var toTargetDir = getDirectToTarget(selfNode, targetPos)
		
		var desiredVelocity = toTargetDir * selfNode.LeapSpeed
	
		# Use steering to smooth our movement towards desired vector
		var steer = (desiredVelocity - selfNode.velocity)
		return selfNode.velocity.move_toward(selfNode.velocity + (steer * leapSmoothForce), selfNode.LeapAcceleration * delta)
	else:
		return .getMovementVelocity(selfNode, targetPos, delta)
	
	
	
