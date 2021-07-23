class_name ShopKeep extends Area2D

var shopAvailable : bool = true setget setAvailable

onready var particles := $Particles2D
onready var sprite := $AnimatedSprite
onready var collision := $StaticBody2D/CollisionShape
onready var label := $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	self.shopAvailable = true
	label.visible = false

func setAvailable(value):
	if value != shopAvailable:
		particles.emitting = true
	
	shopAvailable = value
	if shopAvailable:
		sprite.visible = true
		collision.disabled = false
	else:
		sprite.visible = false
		collision.disabled = true
		label.visible = false

func _on_ShopKeep_body_entered(body):
	if shopAvailable:
		label.visible = true

func _on_ShopKeep_body_exited(body):
	label.visible = false
