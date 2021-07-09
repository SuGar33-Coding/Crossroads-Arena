extends Control


var defaultTexture = preload("res://Assets/SmokePuff.png")

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer


func _ready():
	Inventory.connect("inventory_changed", self, "_updateDisplay")
	
	Inventory.getEquipment()[Equipment.EquipmentType.Feet] = get_node(ItemManager.createItem("res://Items/Shoes.tres"))
	for slot in gridContainer.get_children():
		var slotName: String = slot.name
		var slotType = Equipment.EquipmentType[slotName]
		if Inventory.getEquipment()[slotType] != null:
			# grab item icon and replace the default icon with it
			var iconTexture = (Inventory.getEquipment()[slotType] as ItemInstance).getTexture()
			var icon: TextureRect = slot.get_node("Icon")
			icon.texture = iconTexture


func _updateDisplay():
	var equipment := Inventory.getEquipment()
	for slot in equipment.keys():
		var equipmentType = Equipment.EquipmentType.keys()[slot]
		var slotIcon: TextureRect = gridContainer.get_node(equipmentType).get_child(0)
		if equipment[slot] != null:
			# if there's an item, update the slot with that sprite
			slotIcon.texture = (equipment[slot] as ItemInstance).getTexture()
		else:
			# otherwise replace with default texture
			slotIcon.texture = defaultTexture
