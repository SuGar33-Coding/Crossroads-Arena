extends Node

var potion = preload("res://Items/Potion.tres")

var bag:= {
	"Slot1": null,
	"Slot2": null,
	"Slot3": load("res://Items/Shoes.tres"),
	"Slot4": potion
}

var equipment:= {
	Equipment.EquipmentType.Head: null,
	Equipment.EquipmentType.Chest: null,
	Equipment.EquipmentType.Feet: null
}
