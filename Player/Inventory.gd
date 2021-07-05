class_name Inventory extends Resource

signal items_changed(indexes)

export (Array, Resource) var items = []

var potion = preload("res://Items/Potion.tres")

var bag:= {
	"Slot1": null,
	"Slot2": null,
	"Slot3": load("res://Items/Shoes.tres"),
	"Slot4": potion
}

var equipment:= {
	Equipment.EquipmentType.Head: {
		"item": "HealthPotion",
	},
	Equipment.EquipmentType.Chest: null,
	Equipment.EquipmentType.Feet: null
}

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
