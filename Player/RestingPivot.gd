extends Position2D

onready var restingPos = $MeleeRestingPos


func _physics_process(delta):
	# Make sword pivot to correct position
	var toMouse = restingPos.global_position.direction_to(get_global_mouse_position())
	
	self.look_at(get_global_mouse_position())
