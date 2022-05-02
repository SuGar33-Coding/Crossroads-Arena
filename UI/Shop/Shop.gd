class_name ShopUI extends CanvasLayer

onready var controlNode := $Control

func _ready():
	controlNode.visible = false

func toggleVisible():
	controlNode.visible = not controlNode.visible

func isVisible():
	return controlNode.visible

func setVisible(visible : bool):
	controlNode.visible = visible
