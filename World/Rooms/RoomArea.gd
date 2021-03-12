extends Area2D


func _ready():
	# Direct parent should always be the room it's setting the boundary for
	var parent : Room = self.get_parent()
	self.connect("body_entered", parent, "_player_entered")
	self.connect("body_exited", parent, "_player_exited")
	# Room's parent should always be the overarching world/scene
	self.connect("body_entered", parent.get_parent(), "_player_entered_room", [parent])
