extends Movement

class_name MoveAndAvoid

export var SmoothForce : float = .1
export var radius : float = 150

# Calculate direction from three weighted unit vectors:
# - Direction to target
# - Negative potential from closest group member
func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	# Proportionally weight our pathfinding algorithm to how close unit is to target radius
	var toTargetDir := selfNode.global_position.direction_to(targetPos)
	var toTargetWeight := getToTargetWeight(selfNode, targetPos)
	var toTargetVector = toTargetDir * toTargetWeight
	
	# Move away from allies with strength proportional to how close you are to closest ally
	var avoidanceDir := getAvoidanceDir(selfNode)
	var avoidanceWeight := getAvoidanceWeight(selfNode)
	var avoidanceVector = avoidanceDir * avoidanceWeight
	
	# Combine the weights to get the desired direction
	return (toTargetVector + avoidanceVector).normalized()

# Steer towards desired velocity in Movement Direction
func getMovementVelocity(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):	
	var movementDir = getMovementDirection(selfNode, targetPos, delta)
	
	var desiredVelocity = movementDir * selfNode.MaxSpeed
	
	# Use steering to smooth our movement towards desired vector
	var steer = (desiredVelocity - selfNode.velocity)
	return selfNode.velocity.move_toward(selfNode.velocity + (steer * SmoothForce), selfNode.Acceleration * delta)
	
	# If we want to slow the guys down as they get closer, make a vector that points out that scales inversely with distance
	# But then like only weight it half the way

func getIdleVelocity(selfNode: KinematicBody2D, delta: float):
	return selfNode.velocity.move_toward(Vector2.ZERO, selfNode.Friction * delta)
	
# Takes in two bases and rebases given vector to them (should normalize bases before calling)
func rebaseVector(vectorToRebase: Vector2, xBase:Vector2, yBase:Vector2):
	var newVector = Vector2.ZERO
	
	newVector.x = vectorToRebase.dot(xBase) 
	newVector.y = vectorToRebase.dot(yBase)
	
	return newVector

# Weight proportional to distance from radius around target
func getToTargetWeight(selfNode: KinematicBody2D, targetPos: Vector2) -> float:
	return clamp((targetPos - selfNode.global_position).length() / radius, 0, 1)

# Get direction to closest ally
func getAvoidanceDir(selfNode: KinematicBody2D) -> Vector2:
	var ally : KinematicBody2D = selfNode.closestAlly
	if ally != null:
		return ally.global_position.direction_to(selfNode.global_position)
	else:
		return Vector2.ZERO

func getAvoidanceWeight(selfNode: KinematicBody2D) -> float:
	var ally : KinematicBody2D = selfNode.closestAlly
	if ally != null:
		# TODO: did radius/3 for now just to make it so you can get closer to allies before it takes over
		return clamp((radius/3) / (ally.global_position - selfNode.global_position).length(), 0, 1)
	else:
		return 0.0
	
