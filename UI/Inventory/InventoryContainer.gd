extends ColorRect

var inventory = preload("res://Player/Inventory.tres")

func can_drop_data(position, data):
	return data is Dictionary and data.has("item")

func drop_data(position, data):
	inventory.setItem(data.itemIndex, data.item)
