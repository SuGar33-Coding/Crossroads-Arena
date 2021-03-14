extends KinematicBody2D

export(int) var SPEED = 400

onready var hitbox = $hitbox

var velocity = Vector2.ZERO
var playerArrow = false

func _physics_process(delta):
	var test = move_and_collide(velocity * delta)
	if test != null:
		self.queue_free()

func fire(startingPosition : Vector2, startingRotation : float, fromPlayer := false):
	playerArrow = fromPlayer
	self.global_position = startingPosition
	self.global_rotation = startingRotation
	velocity =  Vector2(1,0).rotated(self.global_rotation) * SPEED


func _on_hitbox_area_entered(area):
	if not area.is_in_group("RoomStuff"):
		if playerArrow:
			PlayerStats.currentXP += hitbox.damage
		self.queue_free()
