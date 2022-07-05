class_name Formation extends Node2D

onready var maxFollowers := get_children().size()

func getTarget(followerIdx : int) -> Vector2:
	if followerIdx < maxFollowers:
		return (get_child(followerIdx) as Position2D).global_position
	else:
		push_warning("Index for orders request is out of range for formation")
		return Vector2.ZERO
