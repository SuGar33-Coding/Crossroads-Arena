class_name ShopUI extends CanvasLayer

onready var controlNode := $Control

signal visible_toggle(visible)

func _ready():
	controlNode.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("pause") and controlNode.visible:
		toggleVisible()

func toggleVisible():
	controlNode.visible = not controlNode.visible
	
	emit_signal("visible_toggle", isVisible())

func isVisible() -> bool:
	return controlNode.visible
