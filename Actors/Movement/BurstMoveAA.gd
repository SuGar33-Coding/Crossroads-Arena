extends MoveAndAvoid

class_name BurstMoveAA

func getMovementVelocity(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	
	var movementDir = getMovementDirection(selfNode, targetPos, delta)
	
	# Only move in one burst when the timer is stopped
	var mvmtTimer : Timer = selfNode.movementTimer
	if(mvmtTimer.is_stopped()):
		mvmtTimer.start(selfNode.movementMaxTime)
		return movementDir * selfNode.MaxSpeed
	else:
		return selfNode.velocity.move_toward(Vector2.ZERO, selfNode.Acceleration * delta)
