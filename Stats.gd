extends Node

export(int) var maxHealth = 1 setget setMaxHealth, getMaxHealth

var health = maxHealth setget setHealth, getHealth

signal noHealth
signal healthChanged(value)
signal maxHealthChanged(value)

func _ready():
	health = maxHealth

func setMaxHealth(value):
	maxHealth = max(value, 1)
	self.health = min(health, maxHealth)
	emit_signal("maxHealthChanged", maxHealth)
	
func getMaxHealth():
	return maxHealth
	
func setHealth(value):
	health = clamp(value, 0, maxHealth)
	emit_signal("healthChanged", health)
	if (health <= 0):
		emit_signal("noHealth")
		
func getHealth():
	return health

func _on_hurtbox_area_entered(area):
	self.health -= 1
