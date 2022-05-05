class_name InventoryUI extends CanvasLayer

onready var playerStats : PlayerStats = get_node("/root/PlayerStats")
onready var controlNode := $Control

onready var sprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite
onready var headSprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite/HeadSprite
onready var chestSprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite/ChestSprite
onready var legSprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite/LegSprite

func _ready():
	controlNode.visible = false
	Inventory.connect("inventory_changed", self, "updateStats")

func toggleVisible():
	controlNode.visible = not controlNode.visible
	updateStats()

func isVisible():
	return controlNode.visible

func setVisible(visible : bool):
	controlNode.visible = visible
	updateStats()

func updateStats(_bag1 = null, _bag2 = null):
	#strLabel.text = str(playerStats.baseStr)
	#conLabel.text = str(playerStats.baseCon)
	#dexLabel.text = str(playerStats.baseDex)
	
	var world = get_tree().current_scene
	var playerNode = world.getPlayerNode()
	
	headSprite.texture = playerNode.headSprite.texture
	chestSprite.texture = playerNode.chestSprite.texture
	legSprite.texture = playerNode.legSprite.texture
