extends Movement

class_name Pathfind

# Get direction to next position in path
func getMovementDirection(selfNode: KinematicBody2D, targetPos: Vector2, delta: float):
	if (selfNode.path as PoolVector2Array).size() <= 0:
		print("out of pos")
		# Out of path nodes, just sit tight
		return Vector2.ZERO
	
	var curPathPos: Vector2
	curPathPos = selfNode.path[0]
	
	if selfNode.global_position.distance_to(curPathPos) < 10:
		print("too close")
		# You're close enough, delete this one and move onto the next one
		selfNode.path.remove(0) # WHY ISNT THIS REMOVING ANYTHING
		return Vector2.ZERO
	
	return selfNode.global_position.direction_to(curPathPos)
