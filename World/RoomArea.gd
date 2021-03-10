extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent : Room = self.get_parent()
	self.connect("body_entered", parent, "_player_entered")
	self.connect("body_exited", parent, "_player_exited")
	self.connect("body_entered", parent.get_parent(), "_player_entered_room", [parent])
