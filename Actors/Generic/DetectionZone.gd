extends Area2D

var target = null

func can_see_target():
	return target != null
	

func _on_DetectionZone_body_entered(body):
	if target == null:
		target = body


func _on_DetectionZone_body_exited(body):
	if body == target:
		var possibleTargets = self.get_overlapping_bodies()
		var targetPos = possibleTargets.find(target)
		if targetPos >= 0:
			possibleTargets.remove(possibleTargets.find(target))
			if not possibleTargets.empty():
				print(possibleTargets[0])
				target = possibleTargets[0]
			else:
				target = null
