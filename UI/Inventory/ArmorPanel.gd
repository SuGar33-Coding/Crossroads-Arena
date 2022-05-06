extends InventoryPanel 

onready var weaponGrid : GridContainer = $Background/MarginContainer/VBoxContainer/HBoxContainer/WeaponContainer/GridContainer

func _ready():
	getGridContainer()
	Inventory.connect("inventory_changed", self, "_updateDisplay")

	for slot in Inventory.getArmor().keys():
		if Inventory.getArmor()[slot] != null:
			# grab item icon and replace the default icon with it
			var iconTexture = (Inventory.getArmor()[slot] as ItemInstance).getTexture()
			var equipmentType = Armor.Type.keys()[slot]
			var icon: TextureRect = gridContainer.get_node(equipmentType).get_node("Icon")
			icon.texture = iconTexture

func getGridContainer():
	gridContainer = $Background/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/GridContainer

func _updateDisplay(_from_panel, _to_panel):
	var equipment := Inventory.getArmor()
	for slot in equipment.keys():
		var equipmentType = Armor.Type.keys()[slot]
		var slotIcon: TextureRect = gridContainer.get_node(equipmentType).get_child(0).get_child(0)
		var defaultIcon: TextureRect = gridContainer.get_node(equipmentType).get_child(0).get_child(1)
		if equipment[slot] != null:
			# if there's an item, update the slot with that sprite
			slotIcon.texture = (equipment[slot] as ItemInstance).getTexture()
			defaultIcon.visible = false
		else:
			# otherwise replace with default texture
			slotIcon.texture = null
			defaultIcon.visible = true
	
	var weapons := Inventory.getWeapons()
	.updateDisplay(weapons, weaponGrid)
