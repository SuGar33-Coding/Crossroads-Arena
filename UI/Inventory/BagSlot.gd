extends TextureRect


func get_drag_data(_position):
	var bagSlot = get_parent().name
	if Inventory.getBag()[bagSlot] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "Bag"
		data.originItemSlot = bagSlot 
		data.originEquipmentType = (
			((Inventory.getBag()[bagSlot] as ItemInstance).resource as Equipment).equipmentType
			if (Inventory.getBag()[bagSlot] as ItemInstance).resource is Equipment
			else null
		)

		var dragTexture = TextureRect.new()
		dragTexture.expand = true
		dragTexture.texture = texture
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
		if data.originPanel == "Equipment":
			# if the item is an equipped equipment
			if Inventory.getBag()[targetBagSlot] is Equipment:
				var targetEquipmentType = Inventory.getBag()[targetBagSlot].equipmentType
				# don't let us make an illegal swap
				return targetEquipmentType == data.originEquipmentType
			else:
				return false
		else:
			# origin panel is Bag
			return true


func drop_data(_position, data):
	Inventory.swapItems(data.originItemSlot, data.targetItemSlot)
