extends Movement

class_name TestingSteering

export var SmoothForce : float = .02
export var radius : float = 150
export var amplitude : float = .7

const frequency : float = 3.0

# Get direction directly towards target
func getMovementDirection(sourcePos: Vector2, targetPos: Vector2):
	return sourcePos.direction_to(targetPos)

func getMovementVelocity(selfNode: KinematicBody2D, targetNode: Node2D, delta: float):
	# Get the derivative along the sine wave
	var sinDirection : Vector2 = getSinVector(selfNode, delta)
	
	# Proportionally weight our pathfinding algorithm to how close unit is to target
	var pathFindingDir = getMovementDirection(selfNode.global_position, targetNode.global_position)
	var pathFindingWeight : Vector2 = pathFindingDir * clamp((targetNode.global_position - selfNode.global_position).length() / radius, 0, 1)
	
	# Rebase sine wave to be circling around the target
	var perpendicularVector = pathFindingDir.rotated(deg2rad(90))
	var worldSinDirection = rebaseVector(sinDirection, perpendicularVector, pathFindingDir)
	worldSinDirection.x *= (selfNode.noise.get_noise_2d(selfNode.noise.seed, selfNode.noiseY) + 1)
	selfNode.noiseY += 1
	
	# Inversely weight our combat movement vector to how close unit is to target
	var combatWeight =  (worldSinDirection).normalized()  * clamp(radius/(targetNode.global_position - selfNode.global_position).length(), 0, 1)
	
	# Combine the weights to get the desired direction and speed
	var desiredVelocity = (pathFindingWeight + combatWeight).normalized() * selfNode.MaxSpeed
	
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
	
	

