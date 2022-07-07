extends InventorySlot

func getPanelName():
	return 'bag'

func getPanelInventory() -> Dictionary:
	return Inventory.getBag()

func autoEquip():
	var itemInstance = getPanelInventory()[getSlotName()] as ItemInstance
	if (is_instance_valid(itemInstance)):
		var bagPanel = self.get_parent()
		if get_tree().current_scene.get_node("UIHandler").shop.isVisible():
			Inventory.swapItems(getPanelName(), getSlotName(), "sell", "0")
		else:
			var slot = ""
			# make this WAY more abstract/modular
			if itemInstance.resource is Armor:
				slot = (itemInstance.resource as Armor).type
			elif itemInstance.resource is WeaponStats:
				if is_instance_valid(Inventory.getWeapons()["0"]) and not is_instance_valid(Inventory.getWeapons()["1"]):
					slot = "1"
				else:
					slot = "0"
			else:
				var consumablesDict := Inventory.getConsumables()
				for key in consumablesDict.keys():
					if not is_instance_valid(consumablesDict.get(key)):
						slot = key
						break
				
				if slot == "":
					slot = "0"
			Inventory.swapItems(getPanelName(), getSlotName(), itemInstance.itemType, slot)

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
				# TODO: This sucks fix it
				var targetEquipmentType = ((Inventory.getBag()[targetBagSlot] as ItemInstance).resource as Armor).type
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
