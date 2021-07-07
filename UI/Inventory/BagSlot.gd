extends TextureRect


func get_drag_data(_position):
	var bagSlot = get_parent().name
	if Inventory._inventory.bag[bagSlot] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "Bag"
		data.originItemSlot = bagSlot 
		data.originEquipmentType = (
			Inventory._inventory.bag[bagSlot].equipmentType
			if Inventory._inventory.bag[bagSlot] is Equipment
			else null
		)
		data.originTexture = texture

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
	# make sure we can drop item in this slot
	var targetBagSlot = get_parent().name
	data.targetItemSlot = targetBagSlot
	if Inventory._inventory.bag[targetBagSlot] == null:  # move an item
		var defaultTexture = load("res://Assets/SmokePuff.png")
		data.targetTexture = defaultTexture
		return true
	else:  # swap an item
		data.targetTexture = texture
		if data.originPanel == "Equipment":
			if Inventory._inventory.bag[targetBagSlot] is Equipment:
				# if the item is an equipment
				var targetEquipmentType = Inventory._inventory.bag[targetBagSlot].equipmentType
				return targetEquipmentType == data.originEquipmentType  # don't let us make an illegal swap
			else:
				return false
		else:  # origin panel is Bag
			return true


func drop_data(_position, data):
	var targetEquipmentSlot = get_parent().name
	var originSlot = data.originNode.get_parent().name

	Inventory.swapItems(data.originItemSlot, data.targetItemSlot)

	# Update texture of origin
	data.originNode.texture = data.targetTexture

	# Update texture of target
	texture = data.originTexture
