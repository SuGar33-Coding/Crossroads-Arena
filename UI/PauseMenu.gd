extends CanvasLayer

onready var label := $Label
onready var button := $quitGame
onready var controlLabel := $ControlsLabel
onready var controlInfo := $controlsinfo

func _ready():
	label.visible = false
	
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		var paused : bool = get_tree().paused
		get_tree().paused = not paused
		label.visible = not paused
		button.visible = not paused
		controlLabel.visible = not paused
		controlInfo.visible = not paused
