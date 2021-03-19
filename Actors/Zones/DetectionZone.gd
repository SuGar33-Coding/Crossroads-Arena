extends Area2D

export(int) var detectionRange = 300

var target: KinematicBody2D = null

onready var collision = $CollisionShape2D

func _ready():
	# Allow user to set detectionRange in the editor
	# Editing the actual circle resource made it a global change
	var shape : CircleShape2D = CircleShape2D.new()
	shape.radius = detectionRange
	collision.shape = shape

func hasTarget() -> bool:
	return target != null

func _on_body_entered(body: KinematicBody2D):
	if target == null:
		target = body

func _on_body_exited(body: KinematicBody2D):
	if body == target:
		var possibleTargets = self.get_overlapping_bodies()
		# remove the body from the list of bodies, cuz its there still lol
		var targetPos = possibleTargets.find(target)
		if targetPos >= 0:
			possibleTargets.remove(targetPos)
		
		if not possibleTargets.empty():
			target = possibleTargets[0]
		else:
			target = null
