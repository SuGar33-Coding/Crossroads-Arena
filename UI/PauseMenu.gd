extends CanvasLayer

onready var label := $Label

func _ready():
	label.visible = false
	
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		var paused : bool = get_tree().paused
		get_tree().paused = not paused
		label.visible = not paused
