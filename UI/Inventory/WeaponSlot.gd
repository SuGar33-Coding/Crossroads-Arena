extends EquipSlot

func getPanelName():
	return 'weapon'

func getPanelInventory() -> Dictionary:
	return Inventory.getWeapons()

func can_drop_data(_position, data):
	data.targetSlotName = get_parent().name
	# make sure we can drop item of this type into this slot
	return data.originResource is WeaponStats
