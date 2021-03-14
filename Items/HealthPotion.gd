extends Area2D

class_name HealthPotion

export(int) var potionPower = 3

func _on_HealthPotion_body_entered(body):
	if(PlayerStats.health < PlayerStats.maxHealth):
		PlayerStats.health += potionPower
		self.queue_free()
