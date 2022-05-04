extends "res://UI/Inventory/ConsumablePanel.gd"


func _updateDisplay(_from_panel, _to_panel):
	var consumables := Inventory.getConsumables()
	for slot in consumables.keys():
		var slotIcon: TextureRect = gridContainer.get_node(slot).get_child(0).get_child(0).get_child(0)
		var defaultIcon: TextureRect = gridContainer.get_node(slot).get_child(0).get_child(0).get_child(1)
		if consumables[slot] != null:
			# if there's an item, update the slot with that sprite
			slotIcon.texture = (consumables[slot] as ItemInstance).getTexture()
			defaultIcon.visible = false
		else:
			# otherwise replace with default texture
			slotIcon.texture = null
			defaultIcon.visible = true
