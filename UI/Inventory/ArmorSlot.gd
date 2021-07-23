extends InventorySlot

func getPanelName():
	return 'armor'

func getSlotName() -> String:
	return Armor.Type[get_parent().name]

func getPanelInventory() -> Dictionary:
	return Inventory.getArmor()

func can_drop_data(_position, data):
	# make sure we can drop item of this type into this slot
	var targetEquipmentSlot = Armor.Type[get_parent().name]
	data.targetSlotName = targetEquipmentSlot
	# only equipment can go in here
	if (data.originResource is Armor):
		# make sure it fits the slot
		return targetEquipmentSlot == (data.originResource as Armor).type
	else:
		return false
