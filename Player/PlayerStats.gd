extends Node

export(int) var maxHealth = 1 setget setMaxHealth, getMaxHealth

var health = 0 setget setHealth, getHealth

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


func connectHealthChanged(node):
	self.connect("healthChanged", node, "_playerstats_health_changed")
	
func connectMaxHealthChanged(node):
	self.connect("maxHealthChanged", node, "_playerstats_maxhealth_changed")
	
func connectNoHealth(node : Node):
	self.connect("noHealth", node, "_playerstats_no_health")
