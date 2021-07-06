class_name ItemInstance extends Node2D

var resource: Item setget setResource
var sprite := Sprite.new()
var itemName: String

func _ready():
	add_child(sprite)

# update this instance whenever the resource gets changed
func setResource(newResource):
	resource = newResource
	itemName = resource.name
	sprite.texture = resource.texture
