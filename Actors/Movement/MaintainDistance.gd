extends Movement

class_name MaintainDistance

export var SmoothForce : float = .02
export var Radius : float = 200

# Get direction towards radius, colinear to ray from source to target
func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	var distToTarget = selfNode.global_position.distance_to(targetPos)
	# get direction towards target
	var movementDir = selfNode.global_position.direction_to(targetPos)
	if distToTarget - Radius <= 0:
		# if within radius, move away
		movementDir *= -1
	
	return movementDir

# Smoothly maintain minimum distance
func getMovementVelocity(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	
	var movementDir = getMovementDirection(selfNode, targetPos, delta)
	var velocityWeight = clamp(pow(abs(selfNode.global_position.distance_to(targetPos) - Radius), 2.0) / Radius, 0, 1)
	var desiredVelocity = movementDir * selfNode.MaxSpeed * velocityWeight
	
	# Use steering to smooth our movement towards desired vector
	var steer = (desiredVelocity - selfNode.velocity)
	return selfNode.velocity.move_toward(selfNode.velocity + (steer * SmoothForce), selfNode.Acceleration * delta)
