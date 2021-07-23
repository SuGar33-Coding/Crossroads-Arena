extends Popup

var itemInstance: ItemInstance setget setItemInstance

func _process(delta):
	rect_position = get_global_mouse_position()

func setItemInstance(newItemInstance):
	itemInstance = newItemInstance
