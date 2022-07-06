extends InventoryPanel

var tempalteBagSlot = preload("res://UI/Shop/ShopSlot.tscn")

onready var sellSlot = $"Background/MarginContainer/VBoxContainer/Header/0/SlotBg"

func _ready():
	Inventory.connect("inventory_changed", self, "_updateDisplay")
	for slot in Inventory.getShop().keys():
		var newBagSlot = tempalteBagSlot.instance()
		var item := Inventory.getShop()[slot] as ItemInstance
		if item != null:
			var iconTexture := item.getTexture()
			var slotIcon := newBagSlot.get_child(0).get_node("Icon") as TextureRect
			slotIcon.texture = iconTexture
			slotIcon.flip_h = item.flip
			slotIcon.flip_v = item.flip
			
			newBagSlot.get_child(0).get_node("Border").modulate = Constants.getRarityColor(item.itemRarity)
			
		gridContainer.add_child(newBagSlot, true)


func _updateDisplay(_from_panel, _to_panel):
	var bag = Inventory.getShop()
	.updateDisplay(bag)
	
	var item := Inventory._inventory.sell["0"] as ItemInstance
	var slotNode : InventorySlot = sellSlot
	var slotIcon: TextureRect = slotNode.get_child(0)
	var defaultIcon: TextureRect = slotNode.get_child(1)
	var border: Panel = slotNode.get_child(2)
	
	if is_instance_valid(item):
		# if there's an item, update the slot with that sprite
		slotIcon.texture = item.getTexture()
		slotIcon.flip_h = item.flip
		slotIcon.flip_v = item.flip
		defaultIcon.visible = false
		border.modulate = Constants.getRarityColor(item.itemRarity)
	else:
		# otherwise replace with default texture
		slotIcon.texture = null
		defaultIcon.visible = true
		border.modulate = Color(0,0,0)
