class_name BagPanel extends InventoryPanel

var tempalteBagSlot = preload("res://UI/Inventory/BagSlot.tscn")

func _ready():
	Inventory.connect("inventory_changed", self, "_updateDisplay")
	for slot in Inventory.getBag().keys():
		var newBagSlot = tempalteBagSlot.instance()
		if Inventory.getBag()[slot] != null:
			var iconTexture = (Inventory.getBag()[slot] as ItemInstance).getTexture()
			(newBagSlot.get_child(0).get_node("Icon") as TextureRect).texture = iconTexture
		gridContainer.add_child(newBagSlot, true)


func _updateDisplay(_from_panel, _to_panel):
	var bag := Inventory.getBag()
	.updateDisplay(bag)
