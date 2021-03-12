extends KinematicBody2D

export(int) var SPEED = 400
var velocity = Vector2.ZERO

func _physics_process(delta):
	var test = move_and_collide(velocity * delta)
	if test != null:
		self.queue_free()

func fire(startingPosition : Vector2, startingRotation : float):
	self.global_position = startingPosition
	self.global_rotation = startingRotation
	velocity =  Vector2(1,0).rotated(self.global_rotation) * SPEED


func _on_hitbox_area_entered(area):
	if not area.is_in_group("RoomStuff"):
		self.queue_free()
