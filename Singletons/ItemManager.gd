extends Node

# Insatnce an item based on an Item resource and return its NodePath in the
# ItemManager
func createItemFromPath(resourcePath: String):
	var resource: Item = load(resourcePath)
	return createItemFromResource(resource)

func createItemFromResource(resource : Item):
	var item : ItemInstance
	if resource is WeaponStats:
		item = WeaponInstance.new()
	else:
		item = ItemInstance.new()
	item.resource = resource
	
	if resource.modifiers.size() > 0:
		var modifier: Modifier = resource.modifiers[randi() % resource.modifiers.size()]
		item.modifier = modifier
	
	add_child(item)
	
	return item.get_path()
