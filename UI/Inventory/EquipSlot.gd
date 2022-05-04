class_name EquipSlot extends InventorySlot

func autoEquip():
	var itemInstance = getPanelInventory()[getSlotName()] as ItemInstance
	if (is_instance_valid(itemInstance)):
		
		var bagDict := Inventory.getBag()
		for key in bagDict.keys():
			if not is_instance_valid(bagDict.get(key)):
				Inventory.swapItems(getPanelName(), getSlotName(), "bag", key)
				break

