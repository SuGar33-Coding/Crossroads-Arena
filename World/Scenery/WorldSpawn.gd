class_name WorldSpawn extends Node2D

onready var wallCollision : Area2D = $WallCollision

var checkedOthers : bool = false

func _physics_process(_delta):
	if is_instance_valid(wallCollision) and checkedOthers:
		var overlappingBods : Array = wallCollision.get_overlapping_bodies()
		overlappingBods.erase(self)
		if overlappingBods.size() > 0:
			self.queue_free()
			#wallCollision.queue_free()
		else:
			wallCollision.queue_free()

func checkWalls(removedChildren : Array) -> bool:
	var overlappingBods = wallCollision.get_overlapping_bodies()
	#overlappingBods.append_array(wallCollision.get_overlapping_areas())
	var trueOverlapping := []
	for bod in overlappingBods:
		if not bod in overlappingBods and bod != self:
			trueOverlapping.append(bod)
	if trueOverlapping.size() > 0:
		self.queue_free()
		return true
	else:
		#wallCollision.queue_free()
		checkedOthers = true
		return false
