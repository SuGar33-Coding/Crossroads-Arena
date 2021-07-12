extends Area2D

# TODO: Only using this as export for testing purposes
var item : ItemInstance
var playerInZone := false

onready var itemSprite = $ItemSprite
onready var tooltipPanel = $PanelContainer
onready var nameLabel = $PanelContainer/VBoxContainer/HBoxContainer/NameLabel

func init(itemInstance: ItemInstance):
	item = itemInstance


# TODO: Adjust starting height and animation height based on sprite size
func _ready():
	tooltipPanel.visible = false
	itemSprite.texture = item.getTexture()
	nameLabel.text = item.itemName

func _physics_process(_delta):
	if(playerInZone and Input.is_action_just_pressed("use")):
		Inventory.addItemToBag(item)
		queue_free()


func _on_Node2D_body_entered(body):
	playerInZone = true
	tooltipPanel.visible = true
	


func _on_Node2D_body_exited(body):
	playerInZone = false
	tooltipPanel.visible = false
