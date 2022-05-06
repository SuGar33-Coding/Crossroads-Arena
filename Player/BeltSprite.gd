class_name BeltSprite extends Sprite


var slot : String

func _ready():
	Inventory.connect("inventory_changed", self, "_updateSprite")
	slot = self.name
	self.texture = null

func _updateSprite(from, to):
	if from == "consumable" or to == "consumable":
		var itemResource : ItemInstance = Inventory.getConsumables()[slot]
		if is_instance_valid(itemResource):
			self.texture = itemResource.sprite.texture
		else:
			self.texture = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
