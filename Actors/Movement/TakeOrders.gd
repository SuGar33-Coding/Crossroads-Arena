class_name TakeOrders extends Movement

func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, _delta: float):
#	if is_instance_valid(selfNode.leader):
	var target = (selfNode.leader as Leader).getTarget(selfNode)
	print(target)
	return .getToTargetDirection(selfNode, target)
