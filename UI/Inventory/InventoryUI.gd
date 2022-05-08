class_name InventoryUI extends CanvasLayer

onready var playerStats : PlayerStats = get_node("/root/PlayerStats")
onready var controlNode := $Control

onready var sprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite
onready var headSprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite/HeadSprite
onready var chestSprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite/ChestSprite
onready var legSprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite/LegSprite
onready var backSprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite/BackWeapon
onready var frontSprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite/FrontWeapon
onready var shieldSprite : Sprite = $Control/Armor/Background/MarginContainer/VBoxContainer/HBoxContainer/Control/Sprite/Shield

var playerNode

func _ready():
	controlNode.visible = false
	Inventory.connect("inventory_changed", self, "updateStats")
	
	var world = get_tree().current_scene
	playerNode = world.getPlayerNode()
	
	shieldSprite.position.x = playerNode.shieldSprite.position.x

func toggleVisible():
	controlNode.visible = not controlNode.visible
	updateStats()

func isVisible():
	return controlNode.visible

func setVisible(visible : bool):
	controlNode.visible = visible
	updateStats()

func updateStats(_bag1 = null, _bag2 = null):
	headSprite.texture = playerNode.headSprite.texture
	chestSprite.texture = playerNode.chestSprite.texture
	legSprite.texture = playerNode.legSprite.texture
	
	backSprite.texture = playerNode.backSprite.texture
	backSprite.flip_v = playerNode.backSprite.flip_v
	backSprite.flip_h = not backSprite.flip_v
	backSprite.hframes = playerNode.backSprite.hframes
	
	frontSprite.texture = playerNode.weaponSprite.texture
	frontSprite.flip_v = playerNode.weaponSprite.flip_v
	frontSprite.flip_h = not frontSprite.flip_v
	frontSprite.hframes = playerNode.weaponSprite.hframes
	
	shieldSprite.visible = playerNode.shieldSprite.visible
	shieldSprite.texture = playerNode.shieldSprite.texture
