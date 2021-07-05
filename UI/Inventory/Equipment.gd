extends Control

var inventory: Inventory = preload("res://Player/Inventory.tres")

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	for slot in gridContainer.get_children():
		var slotName: String = slot.name
		var slotType = Equipment.EquipmentType[slotName]
		if inventory.equipment[slotType] != null:
			# grab item icon and replace the default icon with it
			var itemName = inventory.equipment[slotType].name
			var iconTexture = load("res://Assets/ItemAssets/" + itemName + ".png")
			var icon: TextureRect = slot.get_node("Icon")
			icon.texture = iconTexture
