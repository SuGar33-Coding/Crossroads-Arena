extends Node

signal inventory_changed

var potion = preload("res://Items/Potion.tres")

var _inventory := {
	"bag": {
		"Slot1": null,
		"Slot2": null,
		"Slot3": null,
		"Slot4": null,
	},
	"equipment": {
		Equipment.EquipmentType.Head: null,
		Equipment.EquipmentType.Chest: null,
		Equipment.EquipmentType.Feet: null
	}
}


func isBagFull():
	for slot in _inventory.bag.keys():
		if _inventory.bag[slot] == null:
			return false
	return true


func addItemToBag(item: ItemInstance):
	for slot in _inventory.bag.keys():
		if _inventory.bag[slot] == null:
			_inventory.bag[slot] = item
			emit_signal("inventory_changed")


func swapItems(slot1, slot2):
	# get locations of items
	var location1
	var location2
	for location in _inventory.keys():
		if slot1 in _inventory[location].keys():
			location1 = location
			break
	for location in _inventory.keys():
		if slot2 in _inventory[location].keys():
			location2 = location
			break

	# do da swappe
	var item1 = _inventory[location1][slot1]
	_inventory[location1][slot1] = _inventory[location2][slot2]
	_inventory[location2][slot2] = item1
	emit_signal("inventory_changed")
