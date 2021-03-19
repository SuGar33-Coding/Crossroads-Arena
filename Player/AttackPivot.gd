extends AttackPivot

# TODO: Make this a signal call
onready var animationPlayer := get_node("../AnimationPlayer")


func _physics_process(_delta):
	
	self.lookAtTarget(get_global_mouse_position())
	
	if Input.is_action_just_pressed("attack"):
		animationPlayer.play("MeleeAttack")
		
		var animLength = animationPlayer.current_animation_length
		self.startAttack(animLength)
