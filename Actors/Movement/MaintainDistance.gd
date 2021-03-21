extends Movement

class_name MaintainDistance

export var SmoothForce : float = .02
export var radius : float = 150

# Get direction towards radius, colinear to ray from source to target
func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2):
	var distToTarget = selfNode.global_position.distance_to(targetPos)
	# get direction towards target
	var movementDir = selfNode.global_position.direction_to(targetPos)
	if distToTarget - radius <= 0:
		# if within radius, move away
		movementDir *= -1
	
	return movementDir

# func getMovementVelocity(selfNode: KinematicBody2D, targetNode: Node2D, delta: float):
