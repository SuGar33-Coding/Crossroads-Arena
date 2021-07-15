extends Area2D

# TODO: Only using this as export for testing purposes
var item : ItemInstance
var itemResource : Item
var playerInZone := false
var mouseInZone := false
var highlightShader := preload("res://FX/HighlightFX.shader")
var LabelContainer := preload("res://UI/TooltipLabel.tscn")

onready var itemSprite = $ItemSprite
onready var tooltipPanel = $PanelContainer
onready var vboxContainer = $PanelContainer/VBoxContainer
onready var nameLabel = $PanelContainer/VBoxContainer/CenterContainer/Label

func init(itemInstance: ItemInstance):
	item = itemInstance


# TODO: Adjust starting height and animation height based on sprite size
func _ready():
	tooltipPanel.visible = false
	itemSprite.texture = item.getTexture()
	nameLabel.text = item.itemName
	itemSprite.material = ShaderMaterial.new()
	
	itemResource = item.resource
	if itemResource is Armor:
		addNewLabel("Type:   " + Armor.Type.keys()[itemResource.type])
		addNewLabel("DEF:   " + str(itemResource.defenseValue))
		addNewLabel("SPD:   " + str(itemResource.speedModifier))
	elif itemResource is Consumable:
		pass
	else:
		pass

func addNewLabel(labelString : String):
	var newContainer = LabelContainer.instance()
	var label = newContainer.get_child(0)
	label.text = labelString
	vboxContainer.add_child(newContainer)
	

func _physics_process(_delta):
	if(playerInZone and mouseInZone and Input.is_action_just_pressed("use")):
		Inventory.addItemToBag(item)
		queue_free()


func _on_Node2D_body_entered(body):
	playerInZone = true
	if mouseInZone:
		(itemSprite.material as ShaderMaterial).shader = highlightShader


func _on_Node2D_body_exited(body):
	playerInZone = false
	(itemSprite.material as ShaderMaterial).shader = null


func _on_MouseArea_mouse_entered():
	mouseInZone = true
	tooltipPanel.visible = true
	if playerInZone:
		(itemSprite.material as ShaderMaterial).shader = highlightShader


func _on_MouseArea_mouse_exited():
	mouseInZone = false
	tooltipPanel.visible = false
	(itemSprite.material as ShaderMaterial).shader = null
