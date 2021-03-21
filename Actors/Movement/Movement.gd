extends Resource

class_name Movement

# Get direction directly towards target
func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	return selfNode.global_position.direction_to(targetPos)

# Accelerate straight along Movement Direction
func getMovementVelocity(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	var movementDir = getMovementDirection(selfNode, targetPos, delta)
	return selfNode.velocity.move_toward(movementDir * selfNode.MaxSpeed, selfNode.Acceleration * delta)

# Deccelerate with Friction
func getIdleVelocity(selfNode: KinematicBody2D, delta: float):
	return selfNode.velocity.move_toward(Vector2.ZERO, selfNode.Friction * delta)
