extends Control

var tempalteBagSlot = preload("res://UI/Inventory/BagSlot.tscn")

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	Inventory.bag.Slot1 = get_node(ItemManager.createItem("res://Items/Potion.tres"))
	
	for slot in Inventory.bag.keys():
		var newBagSlot = tempalteBagSlot.instance()
		if Inventory.bag[slot] != null:
			var iconTexture = Inventory.bag[slot].sprite.texture
			(newBagSlot.get_node("Icon") as TextureRect).texture = iconTexture
		gridContainer.add_child(newBagSlot, true)
