extends Node

# Chance that default modifier is used
const DEFAULT_CHANCE : float = .5
const MODIFIER_PATH : String = "res://Items/Modifiers/"
var defaultModifier : Modifier = preload("res://Items/Modifiers/FlatModifier.tres")
var modifierResources : Array = []

func _ready():
	print("ready")
	var dir = Directory.new()
	if dir.open(MODIFIER_PATH) == OK:
		dir.list_dir_begin(true, true)
		var file_name : String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			elif file_name.ends_with(".tres"):
				var resource := load(MODIFIER_PATH+"/"+file_name)
				if resource is Modifier:
					modifierResources.append(resource)
			file_name = dir.get_next()

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
	
	if item is WeaponInstance:
		chooseModifier(item, resource.modifiers)

	add_child(item)
	
	return item.get_path()

func chooseModifier(weaponInstance : WeaponInstance, itemModifiers : Array = []):
	var modifier : Modifier
	if randf() < DEFAULT_CHANCE:
		modifier = defaultModifier
	elif itemModifiers.size() > 0:
		modifier = itemModifiers[randi() % itemModifiers.size()]
	else:
		modifier = modifierResources[randi() % modifierResources.size()]
	
	weaponInstance.modifier = modifier
