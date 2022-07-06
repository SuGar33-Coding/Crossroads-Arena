extends InventorySlot

func getPanelName():
	return 'sell'

func getPanelInventory() -> Dictionary:
	return Inventory._inventory.sell

func autoEquip():
	var itemInstance = getPanelInventory()[getSlotName()] as ItemInstance
	if is_instance_valid(itemInstance) and itemInstance.value <= Inventory.getCoins():
		var bagDict := Inventory.getBag()
		for key in bagDict.keys():
			if not is_instance_valid(bagDict.get(key)):
				Inventory.swapItems(getPanelName(), getSlotName(), "bag", key)
				break

func get_drag_data(_position):
	var bagSlot = get_parent().name
	if getPanelInventory()[bagSlot] != null:
		var resource := (getPanelInventory()[bagSlot] as ItemInstance).resource
		var data = {}
		data.originNode = self
		data.originPanel = "sell"
		data.originSlotName = bagSlot
		data.originResource = (getPanelInventory()[bagSlot] as ItemInstance).resource

		var dragTexture = TextureRect.new()
		dragTexture.expand = true
		dragTexture.texture = get_child(0).texture
		dragTexture.rect_size = Vector2(50, 50)
		dragTexture.flip_h = resource.flip
		dragTexture.flip_v = resource.flip

		var control = Control.new()
		control.add_child(dragTexture)
		dragTexture.rect_position = -0.5 * dragTexture.rect_size
		set_drag_preview(control)

		return data

# Can always drop item in sell slot
func can_drop_data(_position, data):
	var targetBagSlot = get_parent().name
	data.targetSlotName = targetBagSlot
	
	if data.originPanel == "shop" or data.originPanel == "sell":
		return false
	return true


func drop_data(_position, data):
	Inventory.swapItems(data.originPanel, data.originSlotName, 'sell', data.targetSlotName)
