extends InventoryPanel

var tempalteBagSlot = preload("res://UI/Shop/ShopSlot.tscn")

func _ready():
	Inventory.connect("inventory_changed", self, "_updateDisplay")
	for slot in Inventory.getShop().keys():
		var newBagSlot = tempalteBagSlot.instance()
		if Inventory.getShop()[slot] != null:
			var iconTexture = (Inventory.getShop()[slot] as ItemInstance).getTexture()
			(newBagSlot.get_child(0).get_node("Icon") as TextureRect).texture = iconTexture
		gridContainer.add_child(newBagSlot, true)


func _updateDisplay(_from_panel, _to_panel):
	var bag := Inventory.getShop()
	.updateDisplay(bag)
