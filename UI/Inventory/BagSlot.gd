extends Panel

func get_drag_data(_position):
	var bagSlot = get_parent().name
	if Inventory.getBag()[bagSlot] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "Bag"
		data.originItemSlot = bagSlot
		# TODO: This code probably works
		var itemResource = (Inventory.getBag()[bagSlot] as ItemInstance).resource
		if (itemResource is Armor):
			data.originEquipmentType = itemResource.type

		var dragTexture = TextureRect.new()
		dragTexture.expand = true
		dragTexture.texture = get_child(0).texture
		dragTexture.rect_size = Vector2(100, 100)

		var control = Control.new()
		control.add_child(dragTexture)
		dragTexture.rect_position = -0.5 * dragTexture.rect_size
		set_drag_preview(control)

		return data


func can_drop_data(_position, data):
	var targetBagSlot = get_parent().name
	data.targetItemSlot = targetBagSlot
	if Inventory.getBag()[targetBagSlot] == null:
		# move an item
		return true
	else:
		# swap an item
		if data.originPanel != "Bag":
			# if the item is an equipped equipment
			if Inventory.getBag()[targetBagSlot] is Armor:
				var targetEquipmentType = Inventory.getBag()[targetBagSlot].type
				# don't let us make an illegal swap
				return targetEquipmentType == data.originEquipmentType
			else:
				return false
		else:
			# origin panel is Bag
			return true


func drop_data(_position, data):
	Inventory.swapItems(data.originItemSlot, data.targetItemSlot)
