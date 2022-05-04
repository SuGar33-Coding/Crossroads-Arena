class_name WorldSpawn extends Node2D

onready var wallCollision : Area2D = $WallCollision

func checkWalls():
	print(wallCollision.get_overlapping_areas())
	print(wallCollision.get_overlapping_bodies())
	if wallCollision.get_overlapping_areas().size() > 0 or wallCollision.get_overlapping_bodies().size() > 0:
		self.queue_free()
	else:
		wallCollision.queue_free()
