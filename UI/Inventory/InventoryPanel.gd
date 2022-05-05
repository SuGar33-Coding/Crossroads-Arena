class_name InventoryPanel extends Control

var gridContainer : GridContainer

func _ready():
	getGridContainer()

func getGridContainer():
	gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func updateDisplay(bag):
	for slot in bag.keys():
		var slotIcon: TextureRect = gridContainer.get_node(slot).get_child(0).get_child(0)
		var defaultIcon: TextureRect = gridContainer.get_node(slot).get_child(0).get_child(1)
		if bag[slot] != null:
			# if there's an item, update the slot with that sprite
			var item := bag[slot] as ItemInstance
			slotIcon.texture = item.getTexture()
			slotIcon.flip_h = item.flip
			slotIcon.flip_v = item.flip
			defaultIcon.visible = false
		else:
			# otherwise replace with default texture
			slotIcon.texture = null
			defaultIcon.visible = true
