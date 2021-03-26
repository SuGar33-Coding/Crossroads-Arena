extends Area2D

export(int) var detectionRange = 150
export(int) var leaveRange = 600

var target: KinematicBody2D = null

onready var collision = $CollisionShape2D

func _ready():
	# Allow user to set detectionRange in the editor
	# Editing the actual circle resource made it a global change
	var shape : CircleShape2D = CircleShape2D.new()
	shape.radius = detectionRange
	collision.shape = shape
	
func _physics_process(_delta):
	if hasTarget():
		if target.global_position.distance_to(global_position) >= leaveRange:
			target = getNewTarget()

func hasTarget() -> bool:
	return target != null

func _on_body_entered(body: KinematicBody2D):
	if target == null:
		target = body

# Will find if there is a new valid target
# When periodically switching targets for better AI, stay on target if this returns null
# The physics process will handle switching off when out of range
func getNewTarget() -> KinematicBody2D:
	var possibleTargets = self.get_overlapping_bodies()
	
	var newTarget : KinematicBody2D = null
	var minDist = leaveRange # leaveRange >= detecionRange
	for body in possibleTargets:
		var dist = global_position.distance_to(body.global_position)
		if dist < minDist:
			minDist = dist
			newTarget = body
	
	return newTarget

"""func _on_body_exited(body: KinematicBody2D):
	if body == target:
		var possibleTargets = self.get_overlapping_bodies()
		# remove the body from the list of bodies, cuz its there still lol
		var targetPos = possibleTargets.find(target)
		if targetPos >= 0:
			possibleTargets.remove(targetPos)
		
		if not possibleTargets.empty():
			target = possibleTargets[0]
		else:
			target = null"""
