extends GridContainer

var inventory = preload("res://Player/Inventory.tres")

func _ready():
	inventory.connect("items_changed", self, "onItemsChanged")
	updateInventoryDisplay()

func updateInventoryDisplay():
	for itemIndex in inventory.items.size():
		updateInventorySlotDisplay(itemIndex)

func updateInventorySlotDisplay(itemIndex):
	var inventorySlotDisplay: InventorySlotDisplay = get_child(itemIndex)
	var item = inventory.items[itemIndex]
	inventorySlotDisplay.displayItem(item)

# SIGNAL HANDLERS
func onItemsChanged(indexes):
	for itemIndex in indexes:
		updateInventorySlotDisplay(itemIndex)
