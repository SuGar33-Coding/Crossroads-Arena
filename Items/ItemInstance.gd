class_name ItemInstance extends Node2D

var resource: Item setget _setResource
var modifier: Modifier setget _setModifier
var sprite := Sprite.new()
var itemName: String
var itemType: String
var itemRarity
var value : int

func _ready():
	add_child(sprite)

func getTexture():
	return sprite.texture

# update this instance whenever the resource gets changed
func _setResource(newResource):
	resource = newResource
	itemName = resource.name
	itemRarity = resource.rarity
	# TODO: figure out a better way to do this
	# 1. consolidate WeaponInstance with the resource-based items
	# 2. set the itemType on those somehow
	if resource is Armor:
		itemType = "armor"
	elif resource is Consumable:
		itemType = "consumable"
	sprite.texture = resource.texture
	value = resource.value

func _setModifier(newResource : Modifier):
	modifier = newResource
	value = resource.value * modifier.valueModifier
