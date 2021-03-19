extends Resource

class_name Movement

# Get direction directly towards target
func getMovementDirection(sourcePos: Vector2, targetPos: Vector2):
	return sourcePos.direction_to(targetPos)

func getMovementVelocity(selfNode: KinematicBody2D, targetNode: Node2D, delta: float):
	var movementDir = getMovementDirection(selfNode.global_position, targetNode.global_position)
	return selfNode.velocity.move_toward(movementDir * selfNode.MaxSpeed, selfNode.Acceleration * delta)

func getIdleVelocity(selfNode: KinematicBody2D, delta: float):
	return selfNode.velocity.move_toward(Vector2.ZERO, selfNode.Friction * delta)
