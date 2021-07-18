extends Panel

func get_drag_data(_position):
	var bagSlot = get_parent().name
	if Inventory.getBag()[bagSlot] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "bag"
		data.originSlotName = bagSlot
		data.originResource = (Inventory.getBag()[bagSlot] as ItemInstance).resource

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
	data.targetSlotName = targetBagSlot
	# If item is from the chop, just need to make sure we can afford it
	if data.originPanel == 'shop':
		var bagItemValue : int = 0
		if is_instance_valid(Inventory.getBag()[targetBagSlot]):
			bagItemValue = Inventory.getBag()[targetBagSlot].value
		return (Inventory.getShop()[data.originSlotName] as ItemInstance).value <= (Inventory.getCoins() + bagItemValue)
	
	elif Inventory.getBag()[targetBagSlot] == null:
		# move an item
		return true
	else:
		# swap an item
		if data.originPanel != "bag":
			
			# if the item is an equipped equipment
			if Inventory.getBag()[targetBagSlot].resource is Armor:
				var targetEquipmentType = Inventory.getBag()[targetBagSlot].type
				# don't let us make an illegal swap
				return targetEquipmentType == data.originEquipmentType
			elif Inventory.getBag()[targetBagSlot].resource is WeaponStats:
				return data.originPanel == 'weapon'
			elif Inventory.getBag()[targetBagSlot].resource is Consumable:
				return data.originPanel == 'consumable'
			else:
				return false
		else:
			# origin panel is Bag
			return true


func drop_data(_position, data):
	Inventory.swapItems(data.originPanel, data.originSlotName, 'bag', data.targetSlotName)
