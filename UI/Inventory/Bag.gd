extends Control

var tempalteBagSlot = preload("res://UI/Inventory/BagSlot.tscn")

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	Inventory._inventory.bag.Slot1 = get_node(ItemManager.createItem("res://Items/Potion.tres"))
	
	for slot in Inventory._inventory.bag.keys():
		var newBagSlot = tempalteBagSlot.instance()
		if Inventory._inventory.bag[slot] != null:
			var iconTexture = Inventory._inventory.bag[slot].sprite.texture
			(newBagSlot.get_node("Icon") as TextureRect).texture = iconTexture
		gridContainer.add_child(newBagSlot, true)
