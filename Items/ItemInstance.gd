extends Node2D

export (Resource) var item

onready var sprite := $Sprite

func _ready():
	sprite.texture = item.texture
