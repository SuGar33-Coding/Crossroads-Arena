class_name CollideScenery extends Scenery

var checkedLanes := false

onready var laneCollision : Area2D = $LaneCollision

func _physics_process(_delta):
	if not checkedLanes:
		checkedLanes = true
		if laneCollision.get_overlapping_bodies().size() > 0:
			self.queue_free()
		else:
			laneCollision.queue_free()
