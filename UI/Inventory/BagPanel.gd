extends Control


var tempalteBagSlot = preload("res://UI/Inventory/BagSlot.tscn")
var defaultTexture = preload("res://Assets/SmokePuff.png")

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	Inventory.connect("inventory_changed", self, "_updateDisplay")
	Inventory._inventory.bag.Slot1 = get_node(ItemManager.createItem("res://Items/Potion.tres"))
	
	for slot in Inventory._inventory.bag.keys():
		var newBagSlot = tempalteBagSlot.instance()
		if Inventory._inventory.bag[slot] != null:
			var iconTexture = Inventory._inventory.bag[slot].sprite.texture
			(newBagSlot.get_node("Icon") as TextureRect).texture = iconTexture
		gridContainer.add_child(newBagSlot, true)


func _updateDisplay():
	var bag := Inventory.getBag()
	for slot in bag.keys():
		var slotIcon: TextureRect = gridContainer.get_node(slot).get_child(0)
		if bag[slot] != null:
			# if there's an item, update the slot with that sprite
			slotIcon.texture = (bag[slot] as ItemInstance).getTexture()
		else:
			# otherwise replace with default texture
			slotIcon.texture = defaultTexture
