extends Item

class_name HealthPotion

onready var area : Area2D = $Area2D
onready var collider : CollisionShape2D = $Area2D/CollisionShape2D

func usePot():
	PlayerStats.health += effectAmount
	PlayerStats.removeItemFromInventory(self)

func _on_Area2D_body_entered(body):
	"""if(PlayerStats.health < PlayerStats.maxHealth):
		PlayerStats.health += self.effectAmount
		self.queue_free()"""
	PlayerStats.addItemToInventory(self)
	self.sprite.visible = false
	
	self.collider.set_deferred("disabled", true)
	self.area.set_deferred("monitoring", false)
	self.area.set_deferred("monitorable", false)
	
	
	
