class_name Inventory extends Resource

signal items_changed(indexes)

export (Array, Resource) var items = []

func setItem(itemIndex, item):
	var previousItem = items[itemIndex]
	items[itemIndex] = item
	emit_signal("items_changed", [itemIndex])
	return previousItem

func swapItems(itemIndex, targetItemIndex):
	var targetItem = items[targetItemIndex]
	var item = items[itemIndex]
	items[targetItemIndex] = item
	items[itemIndex] = targetItem
	emit_signal("items_changed", [itemIndex, targetItemIndex])

func removeItem(itemIndex):
	var previousItem = items[itemIndex]
	items[itemIndex] = null
	emit_signal("items_changed", [itemIndex])
	return previousItem
