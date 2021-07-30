extends Area2D

func isColliding():
	return not (self.get_overlapping_bodies().empty())
