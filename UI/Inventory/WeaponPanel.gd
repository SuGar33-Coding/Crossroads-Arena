extends InventoryPanel 

func _ready():
	Inventory.connect("inventory_changed", self, "_updateDisplay")

	for slot in Inventory.getWeapons().keys():
		if Inventory.getWeapons()[slot] != null:
			# grab item icon and replace the getConsumables icon with it
			var iconTexture = (Inventory.getWeapons()[slot] as ItemInstance).getTexture()
			(gridContainer.get_node(slot).get_child(0).get_child(0) as TextureRect).texture = iconTexture


func _updateDisplay(_from_panel, _to_panel):
	var weapons := Inventory.getWeapons()
	.updateDisplay(weapons);
