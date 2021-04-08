extends Area2D

func isColliding():
	print(get_overlapping_bodies())
	print(get_overlapping_areas())
	return not (self.get_overlapping_bodies().empty())
