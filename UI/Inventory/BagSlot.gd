extends TextureRect

var inventory: Inventory = preload("res://Player/Inventory.tres")

func get_drag_data(_position):
	var bagSlot = get_parent().name
	if inventory.bag[bagSlot].item != null:
		var data = {}
		data.originNode = self
		data.originPanel = "Bag"
		data.originItemid = inventory.bag[bagSlot].item
		data.originEquipmentSlot = inventory.bag[bagSlot].equipmentSlot
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
	if inventory.bag[targetBagSlot].item == null: # move an item
		data.targetItemId = null
		data.targetTexture = null
		return true
	else: # swap an item
		data.targetItemId = inventory.bag[targetBagSlot].item
		data.targetTexture = texture
		if data.originPanel == "Equipment":
			var targetEquipmentSlot = inventory.bag[targetBagSlot].equipmentSlot
			return targetEquipmentSlot == data.originEquipmentSlot # don't let us make an illegal swap
		else: # origin panel is Bag
			return true
