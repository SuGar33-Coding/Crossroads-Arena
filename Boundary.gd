extends StaticBody2D

class_name Boundary


onready var sprite = $Sprite
onready var collisionShape = $CollisionShape2D

func isOpen():	
	sprite.visible = false
	collisionShape.disabled = true
	
func isClosed():	
	sprite.visible = true
	collisionShape.disabled = false
