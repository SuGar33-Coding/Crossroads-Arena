extends Movement

class_name Pathfind

export var pointIncrementThreshold = 10

# Get direction to next position in path
func getToTargetDirection(selfNode: KinematicBody2D, targetPos: Vector2):
	# if line of sight go directly toward, else pathfind
	if selfNode.isTargetVisible:
		return .getToTargetDirection(selfNode, targetPos)
		
	#if (selfNode.path as PoolVector2Array).size() <= 0:
	if selfNode.pathIdx >= (selfNode.path as PoolVector2Array).size():
		# Out of path nodes, just sit tight
		return Vector2.ZERO
	
	var curPathPos: Vector2
	curPathPos = selfNode.path[selfNode.pathIdx]
	
	if selfNode.global_position.distance_to(curPathPos) < pointIncrementThreshold:
		# You're close enough, delete this one and move onto the next one
		selfNode.pathIdx += 1
		return Vector2.ZERO
	
	return selfNode.global_position.direction_to(curPathPos)
