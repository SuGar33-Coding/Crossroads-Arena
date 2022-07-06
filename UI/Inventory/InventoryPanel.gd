class_name InventoryPanel extends Control

var gridContainer : GridContainer

func _ready():
	getGridContainer()

func getGridContainer():
	gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func updateDisplay(bag, container : Container = gridContainer):
	for slot in bag.keys():
		var slotNode : InventorySlot = container.get_node(slot).get_child(0)
		var slotIcon: TextureRect = slotNode.get_child(0)
		var defaultIcon: TextureRect = slotNode.get_child(1)
		var border: Panel = slotNode.get_child(2)
		
		if bag[slot] != null:
			# if there's an item, update the slot with that sprite
			var item := bag[slot] as ItemInstance
			slotIcon.texture = item.getTexture()
			slotIcon.flip_h = item.flip
			slotIcon.flip_v = item.flip
			defaultIcon.visible = false
			border.modulate = Constants.getRarityColor(item.itemRarity)
		else:
			# otherwise replace with default texture
			slotIcon.texture = null
			defaultIcon.visible = true
			border.modulate = Color(0,0,0)
