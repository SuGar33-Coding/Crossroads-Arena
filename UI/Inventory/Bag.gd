extends Control

var tempalteBagSlot = preload("res://UI/Inventory/BagSlot.tscn")
var inventory: Inventory = preload("res://Player/Inventory.tres")

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	for slot in inventory.bag.keys():
		var newBagSlot = tempalteBagSlot.instance()
		if inventory.bag[slot] != null:
			var itemName = inventory.bag[slot].name
			var iconTexture = load("res://Assets/ItemAssets/" + itemName + ".png")
			(newBagSlot.get_node("Icon") as TextureRect).texture = iconTexture
		gridContainer.add_child(newBagSlot, true)
