extends Movement

class_name TestingSteering

export var SmoothForce : float = .02
export var radius : float = 150
export var amplitude : float = .5

const frequency : float = 1.0

# Get direction directly towards target
func getMovementDirection(sourcePos: Vector2, targetPos: Vector2):
	return sourcePos.direction_to(targetPos)

func getMovementVelocity(selfNode: KinematicBody2D, targetNode: Node2D, delta: float):
	# Proportionally weight our pathfinding algorithm to how close unit is to target
	var pathfindingDir = getMovementDirection(selfNode.global_position, targetNode.global_position)
	var pathfindingWeight := getPathfindingWeight(selfNode, targetNode, pathfindingDir)
	
	# Get the weight of our combat movement vector
	var combatWeight :=  getCombatWeight(selfNode, targetNode, pathfindingDir, delta)
	
	# Get the weight of moving away from nearby allies to avoid clumping
	var avoidanceWeight := getAvoidanceWeight(selfNode)
	
	# Combine the weights to get the desired direction and speed
	var desiredVelocity = (pathfindingWeight + combatWeight + avoidanceWeight).normalized() * selfNode.MaxSpeed
	
	# Use steering to smooth our movement towards desired vector
	var steer = (desiredVelocity - selfNode.velocity)
	return selfNode.velocity.move_toward(selfNode.velocity + (steer * SmoothForce), selfNode.Acceleration * delta)
	
	
	# If we want to slow the guys down as they get closer, make a vector that points out that scales inversely with distance
	# But then like only weight it half the way

func getIdleVelocity(selfNode: KinematicBody2D, delta: float):
	return selfNode.velocity.move_toward(Vector2.ZERO, selfNode.Friction * delta)

func getSinVector(selfNode: KinematicBody2D, delta: float) -> Vector2:
	# Move along the sin wave
	var newSinX = fmod(selfNode.sinX + delta * selfNode.moveDir, TAU)
	
	# Calculate sin wave positions
	var oldPos = Vector2(selfNode.sinX, cos(selfNode.sinX*frequency)*amplitude)
	var newPos = Vector2(newSinX, cos(newSinX*frequency)*amplitude)
	
	# Update sin x coordinates
	selfNode.sinX = newSinX
	
	# Return derivative between two points
	return oldPos.direction_to(newPos)
	
# Takes in two bases and rebases given vector to them (should normalize bases before calling)
func rebaseVector(vectorToRebase: Vector2, xBase:Vector2, yBase:Vector2):
	var newVector = Vector2.ZERO
	
	newVector.x = vectorToRebase.dot(xBase) 
	newVector.y = vectorToRebase.dot(yBase)
	
	return newVector
	
func getCombatWeight(selfNode: KinematicBody2D, targetNode, pathFindingDir: Vector2, delta: float) -> Vector2:
	# Get the derivative along the sine wave
	var sinDirection : Vector2 = getSinVector(selfNode, delta)
	
	# Rebase the sinDirection to place it on the circle around the target
	var perpendicularVector = pathFindingDir.rotated(deg2rad(90))
	var worldSinDirection = rebaseVector(sinDirection, perpendicularVector, pathFindingDir)
	worldSinDirection.x *= (selfNode.noise.get_noise_2d(selfNode.noise.seed, selfNode.noiseY) + 1)
	selfNode.noiseY += 1
	
	# Inversely weight our combat movement vector to how close unit is to target
	var combatWeight =  (worldSinDirection).normalized()  * clamp(radius/(targetNode.global_position - selfNode.global_position).length(), 0, 1)
	return combatWeight
	
func getPathfindingWeight(selfNode: KinematicBody2D, targetNode: KinematicBody2D, pathfindingDir: Vector2) -> Vector2:
	return pathfindingDir * clamp((targetNode.global_position - selfNode.global_position).length() / radius, 0, 1)
	
func getAvoidanceWeight(selfNode: KinematicBody2D) -> Vector2:
	var ally : KinematicBody2D = selfNode.closestAlly
	if ally != null:
		var dirAwayFromAlly = ally.global_position.direction_to(selfNode.global_position)
		
		# TODO: did radius/3 for now just to make it so you can get closer to allies before it takes over
		return dirAwayFromAlly * clamp((radius/3) / (ally.global_position - selfNode.global_position).length(), 0, 1)
	else:
		return Vector2.ZERO
