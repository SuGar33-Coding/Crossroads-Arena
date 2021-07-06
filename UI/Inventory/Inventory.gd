extends CanvasLayer

onready var bagNode := $Bag
onready var equipmentNode := $Equipment

func _ready():
	bagNode.visible = false
	equipmentNode.visible = false

func _process(delta):
	if Input.is_action_just_pressed("toggleInventory"):
		toggleVisible()

func toggleVisible():
	bagNode.visible = not bagNode.visible
	equipmentNode.visible = not equipmentNode.visible
