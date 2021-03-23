extends MoveAndAvoid

class_name FlankAndPoke

export var amplitude : float = .5

const frequency : float = 1.0

# Calculate direction from three weighted unit vectors:
# - Direction to target
# - Encircle/poke behavior
# - Negative potential from closest group member
func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	# Proportionally weight our pathfinding algorithm to how close unit is to target radius
	var toTargetDir := selfNode.global_position.direction_to(targetPos)
	var toTargetWeight := getToTargetWeight(selfNode, targetPos)
	var toTargetVector = toTargetDir * toTargetWeight
	
	# Inversely weight combat movement with how close unit is to target radius
	var combatDir := getCombatDir(selfNode, toTargetDir, delta)
	var combatWeight :=  getCombatWeight(selfNode, targetPos)
	var combatVector = combatDir * combatWeight
	
	# Move away from allies with strength proportional to how close you are to closest ally
	var avoidanceDir := getAvoidanceDir(selfNode)
	var avoidanceWeight := getAvoidanceWeight(selfNode)
	var avoidanceVector = avoidanceDir * avoidanceWeight
	
	# Combine the weights to get the desired direction
	return (toTargetVector + combatVector + avoidanceVector).normalized()

# Steer towards desired velocity in Movement Direction
func getMovementVelocity(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):	
	var movementDir = getMovementDirection(selfNode, targetPos, delta)
	
	var desiredVelocity = movementDir * selfNode.MaxSpeed
	
	# Use steering to smooth our movement towards desired vector
	var steer = (desiredVelocity - selfNode.velocity)
	return selfNode.velocity.move_toward(selfNode.velocity + (steer * SmoothForce), selfNode.Acceleration * delta)
	
	# If we want to slow the guys down as they get closer, make a vector that points out that scales inversely with distance
	# But then like only weight it half the way

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
	
func getCombatDir(selfNode: KinematicBody2D, pathFindingDir: Vector2, delta: float) -> Vector2:
	# Get the derivative along the sine wave
	var sinDirection : Vector2 = getSinVector(selfNode, delta)
	
	# Rebase the sinDirection to place it on the circle around the target
	var perpendicularVector = pathFindingDir.rotated(deg2rad(90))
	var worldSinDirection = rebaseVector(sinDirection, perpendicularVector, pathFindingDir)
	# Add random jiggle to the vector
	worldSinDirection.x *= (selfNode.noise.get_noise_2d(selfNode.noise.seed, selfNode.noiseY) + 1)
	selfNode.noiseY += 1
	
	return worldSinDirection.normalized()
	
func getCombatWeight(selfNode: KinematicBody2D, targetPos: Vector2) -> float:
	# Inversely weight our combat movement vector to how close unit is to target
	return clamp(radius/(targetPos - selfNode.global_position).length(), 0, 1)

# Weight proportional to distance from radius around target
func getToTargetWeight(selfNode: KinematicBody2D, targetPos: Vector2) -> float:
	return clamp((targetPos - selfNode.global_position).length() / radius, 0, 1)

