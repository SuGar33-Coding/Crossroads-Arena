class_name InventorySlotDisplay extends CenterContainer

var emptyInventorySlotImage: StreamTexture = preload("res://Assets/SmokePuff.png")
var inventory = preload("res://Player/Inventory.tres")

onready var itemTextureRect = $ItemTextureRect

func displayItem(item: Item):
	if item is Item:
		itemTextureRect.texture = item.texture
	else:
		itemTextureRect.texture = emptyInventorySlotImage

func get_drag_data(_position):
	var itemIndex = get_index()
	var item = inventory.removeItem(itemIndex)
	
	if item is Item:
		var data = {}
		data.item = item
		data.itemIndex = itemIndex
		
		var dragPreview = TextureRect.new()
		dragPreview.texture = item.texture
		set_drag_preview(dragPreview)
		
		return data

func can_drop_data(_position, data):
	return data is Dictionary and data.has("item")

func drop_data(_position, data):
	var myItemIndex = get_index()
	var myItem = inventory.items[myItemIndex]
	inventory.swapItems(myItemIndex, data.itemIndex)
	
	inventory.setItem(myItemIndex, data.item)
