extends Panel

func get_drag_data(_position):
	var bagSlot = get_parent().name
	if Inventory.getShop()[bagSlot] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "shop"
		data.originSlotName = bagSlot
		data.originResource = (Inventory.getShop()[bagSlot] as ItemInstance).resource

		var dragTexture = TextureRect.new()
		dragTexture.expand = true
		dragTexture.texture = get_child(0).texture
		dragTexture.rect_size = Vector2(100, 100)

		var control = Control.new()
		control.add_child(dragTexture)
		dragTexture.rect_position = -0.5 * dragTexture.rect_size
		set_drag_preview(control)

		return data

# Can only drag in items from bag, true as long as they can afford item in this spot
func can_drop_data(_position, data):
	var targetBagSlot = get_parent().name
	data.targetSlotName = targetBagSlot
	
	if data.originPanel == "shop":
		return false
	elif Inventory.getShop()[targetBagSlot] == null:
		# move an item
		return true
	else:
		# swap an item
		var targetItem : ItemInstance = Inventory.getShop()[targetBagSlot]
		# Check if price of item in shop is more than current coins + coins they would get from selling item they're trying to swap
		if targetItem.value > Inventory.getCoins() + Inventory.getBag()[data.originSlotName].value:
			return false
		else:
			return true


func drop_data(_position, data):
	Inventory.swapItems(data.originPanel, data.originSlotName, 'shop', data.targetSlotName)
