class_name Movement extends Resource

# Get direction directly towards target
func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, _delta: float):
	return getToTargetDirection(selfNode, targetPos)

# Accelerate straight along Movement Direction
func getMovementVelocity(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	var movementDir = getMovementDirection(selfNode, targetPos, delta)
	return selfNode.velocity.move_toward(movementDir * selfNode.MaxSpeed, selfNode.Acceleration * delta)

# Deccelerate with Friction
func getIdleVelocity(selfNode: KinematicBody2D, delta: float):
	return selfNode.velocity.move_toward(Vector2.ZERO, selfNode.Friction * delta)
	
func getToTargetDirection(selfNode: KinematicBody2D, targetPos: Vector2):
	return selfNode.global_position.direction_to(targetPos)

func getToTargetWeight(_selfNode: KinematicBody2D, _targetPos: Vector2) -> float:
	return 1.0
