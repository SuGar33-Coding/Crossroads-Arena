extends TextureRect

var inventory: Inventory = preload("res://Player/Inventory.tres")

func get_drag_data(_position):
	var equipmentType = Equipment.EquipmentType[get_parent().name]
	if inventory.equipment[equipmentType] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "Equipment"
		data.originItemResource = inventory.equipment[equipmentType]
		data.originEquipmentType = equipmentType
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
	# make sure we can drop item of this type into this slot
	var targetEquipmentSlot = Equipment.EquipmentType[get_parent().name]
	if targetEquipmentSlot == data.originEquipmentType:
		# get the target data as we hover
		if inventory.equipment[targetEquipmentSlot] == null:
			data.targetItemResource = null
			data.targetTexture = null
		else:
			data.targetItemResource = inventory.equipment[targetEquipmentSlot]
			data.targetTexture = texture
		return true
	else:
		return false

func drop_data(_position, data):
	var targetEquipmentSlot = Equipment.EquipmentType[get_parent().name]
	var originSlot = data.originNode.get_parent().name
	
	# Update inventory data of origin
	if data.originPanel == "Bag":
		inventory.bag[originSlot] = data.targetItemResource
	elif data.originPanel == "Equipment":
		inventory.equipment[Equipment.EquipmentType[originSlot]] = data.targetItemResource
	
	# Update texture of origin
	if data.targetItemResource == null:
		var defaultTexture = load("res://Assets/SmokePuff.png")
		data.originNode.texture = defaultTexture
	else:
		data.originNode.texture = data.targetTexture
	
	# Update texture and inventory data of target
	inventory.equipment[targetEquipmentSlot] = data.originItemResource
	texture = data.originTexture
