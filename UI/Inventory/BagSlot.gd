extends TextureRect

var inventory: Inventory = preload("res://Player/Inventory.tres")

func get_drag_data(_position):
	var bagSlot = get_parent().name
	if inventory.bag[bagSlot] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "Bag"
		data.originItemName = inventory.bag[bagSlot].name
		data.originEquipmentType = inventory.bag[bagSlot].equipmentType if inventory.bag[bagSlot] is Equipment else null
		data.originTexture = texture
		
		var dragTexture = TextureRect.new()
		dragTexture.expand = true
		dragTexture.texture = texture
		dragTexture.rect_size = Vector2(100,100)
		
		var control = Control.new()
		control.add_child(dragTexture)
		dragTexture.rect_position = -0.5 * dragTexture.rect_size
		set_drag_preview(control)
		
		return data

func can_drop_data(_position, data):
	# make sure we can drop item in this slot
	var targetBagSlot = get_parent().name
	if inventory.bag[targetBagSlot] == null: # move an item
		data.targetItemId = null
		data.targetTexture = null
		return true
	else: # swap an item
		data.targetItemName = inventory.bag[targetBagSlot].name
		data.targetTexture = texture
		if data.originPanel == "Equipment":
			if inventory.bag[targetBagSlot] is Equipment:
				# if the item is an equipment
				var targetEquipmentType = inventory.bag[targetBagSlot].equipmentType
				return targetEquipmentType == data.originEquipmentType # don't let us make an illegal swap
			else:
				return false
		else: # origin panel is Bag
			return true
