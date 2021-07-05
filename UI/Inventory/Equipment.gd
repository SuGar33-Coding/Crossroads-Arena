extends Control

var inventory: Inventory = preload("res://Player/Inventory.tres")

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	for slot in gridContainer.get_children():
		var slotName: String = slot.name
		var slotType = Equipment.EquipmentType[slotName]
		if inventory.equipment[slotType] != null:
			# grab item icon and replace the default icon with it
			var iconTexture = (inventory.equipment[slotType] as Item).texture
			var icon: TextureRect = slot.get_node("Icon")
			icon.texture = iconTexture
