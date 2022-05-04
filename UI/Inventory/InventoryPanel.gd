class_name InventoryPanel extends Control

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func updateDisplay(bag):
	for slot in bag.keys():
		var slotIcon: TextureRect = gridContainer.get_node(slot).get_child(0).get_child(1)
		var defaultIcon: TextureRect = gridContainer.get_node(slot).get_child(0).get_child(0)
		if bag[slot] != null:
			# if there's an item, update the slot with that sprite
			slotIcon.texture = (bag[slot] as ItemInstance).getTexture()
			defaultIcon.visible = false
		else:
			# otherwise replace with default texture
			slotIcon.texture = null
			defaultIcon.visible = true
