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
	var newSinX = fmod(selfNode.sinX + delta * selfNode.moveDir, TAU)
	var oldPos = Vector2(selfNode.sinX, cos(selfNode.sinX*frequency)*amplitude)
	var newPos = Vector2(newSinX, cos(newSinX*frequency)*amplitude)
	var sinDirection = oldPos.direction_to(newPos)
	selfNode.sinX = newSinX
		
	var pathFindingDir = getMovementDirection(selfNode.global_position, targetNode.global_position)
	var pathFindingVelocity : Vector2 = pathFindingDir * clamp((targetNode.global_position - selfNode.global_position).length() / radius, 0, 1)
	
	var perpendicularVector = pathFindingDir.rotated(deg2rad(90))
	var worldSinDirection = Vector2.ZERO
	worldSinDirection.x = sinDirection.dot(perpendicularVector) * (selfNode.noise.get_noise_2d(selfNode.noise.seed, selfNode.noiseY) + 1)
	selfNode.noiseY += 1
	worldSinDirection.y = sinDirection.dot(pathFindingDir)
	
	var combatVelocity =  (worldSinDirection).normalized()  * clamp(radius/(targetNode.global_position - selfNode.global_position).length(), 0, 1)
	var desiredVelocity = (pathFindingVelocity + combatVelocity).normalized() * selfNode.MaxSpeed
	
	var steer = (desiredVelocity - selfNode.velocity)
	return selfNode.velocity.move_toward(selfNode.velocity + (steer * SmoothForce), selfNode.Acceleration * delta)
	
	
	# If we want to slow the guys down as they get closer, make a vector that points out that scales inversely with distance
	# But then like only weight it half the way

func getIdleVelocity(selfNode: KinematicBody2D, delta: float):
	return selfNode.velocity.move_toward(Vector2.ZERO, selfNode.Friction * delta)
