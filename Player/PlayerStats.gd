extends Node

var maxHealth : int = 1 setget setMaxHealth, getMaxHealth
var startingMaxHealth : int = 5 setget setStartingHealth
var playerLevel : int = 0 setget setPlayerLevel
var currentXP : int = 0 setget setCurrentXP, getCurrentXP
var strength : int = 0 setget setStr
var con : int = 0 setget setCon
var dex : int = 0 setget setDex
# AttackSpeed starts at 1 and then will slowly scale down as it's multiplied by weapon attack speed
var attackSpeed : float = 1

signal noHealth
signal healthChanged(value)
signal maxHealthChanged(value)
signal currentXPChanged(newXP)
signal playerLevelChanged(newLevel)
signal addedToInventory(newItem)
signal removedFromInventory(removedItem)

# How much health increases on every level
var healthIncrease = 7
var health = 1 setget setHealth, getHealth
# Will be an array of scenes/references to scene instances
var inventory := []

func setStartingHealth(value):
	startingMaxHealth = value
	self.maxHealth = value
	self.health = value

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
	
func xpToNextLevel() -> int:
	return 10 * playerLevel
	
func setCurrentXP(value):
	currentXP = value
	var nextLevelUp = xpToNextLevel()
	while currentXP >= nextLevelUp:
		currentXP -= nextLevelUp
		self.setPlayerLevel(playerLevel + 1)
	emit_signal("currentXPChanged", currentXP)
	
func getCurrentXP() -> int:
	return currentXP

func setStr(value):
	strength = value
	
func setCon(value):
	if con < value:
		con += 1
		self.maxHealth = startingMaxHealth + con * healthIncrease
		self.health += healthIncrease
	
func setDex(value):
	dex = value
	self.attackSpeed = pow(.925, dex)

func setPlayerLevel(newLevel):
	if playerLevel < newLevel:
		while playerLevel != newLevel:
			playerLevel += 1
			# Increase player's stats here
			if playerLevel % 2 == 0:
				self.con += 1
				self.strength += 1
			self.dex += 1
	
	emit_signal("playerLevelChanged", playerLevel)

func addItemToInventory(item : Item):
	inventory.append(item)
	emit_signal("addedToInventory", item)
	
func removeItemFromInventory(item : Item):
	removeItemFromInvByPos(inventory.find(item))
	
func removeItemFromInvByPos(itemPos : int):
	if itemPos >= 0:
		var itemToRemove = inventory[itemPos]
		inventory.remove(itemPos)
		emit_signal("removedFromInventory", itemToRemove)
	
func getNumItemsOfType(name : String) -> int:
	var numItem = 0
	for i in range(len(inventory)):
		var item : Item = inventory[i]
		if name in item.get_name():
			numItem += 1
	
	return numItem
	
func getItemOfType(name : String) -> Item:
	for i in range(len(inventory)):
		var item : Item = inventory[i]
		if name in item.get_name():
			return item
			
	return null

func _on_hurtbox_area_entered(_area):
	self.health -= 1

func connectHealthChanged(node):
	self.connect("healthChanged", node, "_playerstats_health_changed")
	
func connectMaxHealthChanged(node):
	self.connect("maxHealthChanged", node, "_playerstats_maxhealth_changed")
	
func connectNoHealth(node : Node):
	self.connect("noHealth", node, "_playerstats_no_health")
