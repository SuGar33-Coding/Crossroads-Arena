class_name TakeOrders extends Movement

export var radius : float = 75.0

func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, _delta: float):
	# Proportionally weight our pathfinding algorithm to how close unit is to target radius
	var target = (selfNode.leader as Leader).getFormationPos(selfNode)
	var toTargetDir = getToTargetDirection(selfNode, target)
	var toTargetWeight := getToTargetWeight(selfNode, targetPos)
	var toTargetVector := (toTargetDir * toTargetWeight) as Vector2
	return toTargetVector.normalized()

# Weight proportional to distance from radius around target
func getToTargetWeight(selfNode: KinematicBody2D, targetPos: Vector2) -> float:
	return clamp((targetPos - selfNode.global_position).length() / radius, 0, 1)
