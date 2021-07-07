extends Control

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	for slot in gridContainer.get_children():
		var slotName: String = slot.name
		var slotType = Equipment.EquipmentType[slotName]
		if Inventory._inventory.equipment[slotType] != null:
			# grab item icon and replace the default icon with it
			var iconTexture = (Inventory.equipment[slotType] as Item).texture
			var icon: TextureRect = slot.get_node("Icon")
			icon.texture = iconTexture
