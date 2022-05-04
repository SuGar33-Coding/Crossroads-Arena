extends InventoryPanel

var tempalteBagSlot = preload("res://UI/Shop/ShopSlot.tscn")

func _ready():
	Inventory.connect("inventory_changed", self, "_updateDisplay")
	for slot in Inventory.getShop().keys():
		var newBagSlot = tempalteBagSlot.instance()
		var item := Inventory.getShop()[slot] as ItemInstance
		if item != null:
			var iconTexture := item.getTexture()
			var slotIcon := newBagSlot.get_child(0).get_node("Icon") as TextureRect
			slotIcon.texture = iconTexture
			slotIcon.flip_h = item.flip
			slotIcon.flip_v = item.flip
			
		gridContainer.add_child(newBagSlot, true)


func _updateDisplay(_from_panel, _to_panel):
	var bag := Inventory.getShop()
	.updateDisplay(bag)
