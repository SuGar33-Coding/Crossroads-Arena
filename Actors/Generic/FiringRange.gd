extends Area2D


func targetInRange(target : KinematicBody2D) -> bool:
	return self.get_overlapping_bodies().find(target) != -1
