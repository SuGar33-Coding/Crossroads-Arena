extends Panel

func get_drag_data(_position):
	var armorType = Armor.Type[get_parent().name]
	print(armorType)
	if Inventory.getEquipment()[armorType] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "Armor"
		data.originItemSlot = armorType
		print(data)
		data.originEquipmentType = armorType
		print(data)
		
		var dragTexture = TextureRect.new()
		dragTexture.expand = true
		dragTexture.texture = get_child(0).texture
		dragTexture.rect_size = Vector2(100,100)
		
		var control = Control.new()
		control.add_child(dragTexture)
		dragTexture.rect_position = -0.5 * dragTexture.rect_size
		set_drag_preview(control)
		
		return data

func can_drop_data(_position, data):
	# make sure we can drop item of this type into this slot
	var targetEquipmentSlot = Armor.Type[get_parent().name]
	data.targetItemSlot = targetEquipmentSlot
	# only equipment can go in here, so just make sure it fits the slot
	return targetEquipmentSlot == data.originEquipmentType

func drop_data(_position, data):
	Inventory.swapItems(data.originItemSlot, data.targetItemSlot)
