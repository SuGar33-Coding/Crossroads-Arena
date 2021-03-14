extends Node

export(int) var maxHealth = 1 setget setMaxHealth, getMaxHealth
export(int) var playerLevel = 1 setget setPlayerLevel
export(int) var currentXP = 0 setget setCurrentXP, getCurrentXP
export(float) var attackSpeed = .5

signal noHealth
signal healthChanged(value)
signal maxHealthChanged(value)
signal currentXPChanged(newXP)
signal playerLevelChanged(newLevel)

# How much health increases on every level
var healthIncrease = maxHealth
var health = 0 setget setHealth, getHealth

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
	
func addXP(amount):
	self.setCurrentXP(currentXP + amount)
	
func xpToNextLevel() -> float:
	return pow(10, playerLevel)
	
func setCurrentXP(value):
	currentXP = value
	var nextLevelUp = xpToNextLevel()
	while currentXP >= nextLevelUp:
		currentXP -= nextLevelUp
		self.setPlayerLevel(playerLevel + 1)
	emit_signal("currentXPChanged", currentXP)
	
func getCurrentXP() -> int:
	return currentXP

func setPlayerLevel(newLevel):
	if playerLevel < newLevel:
		while playerLevel != newLevel:
			playerLevel += 1
			# Increase player's stats here
			self.maxHealth += healthIncrease
			self.health += healthIncrease
			self.attackSpeed = self.attackSpeed * .925
	
	emit_signal("playerLevelChanged", playerLevel)


func _on_hurtbox_area_entered(area):
	self.health -= 1

func connectHealthChanged(node):
	self.connect("healthChanged", node, "_playerstats_health_changed")
	
func connectMaxHealthChanged(node):
	self.connect("maxHealthChanged", node, "_playerstats_maxhealth_changed")
	
func connectNoHealth(node : Node):
	self.connect("noHealth", node, "_playerstats_no_health")