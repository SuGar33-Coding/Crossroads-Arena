class_name MaintainAndCharge extends MaintainAndFlank

func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	if not selfNode.charging:
		return .getMovementDirection(selfNode, targetPos, delta)
	else:
		return selfNode.chargeDirection
