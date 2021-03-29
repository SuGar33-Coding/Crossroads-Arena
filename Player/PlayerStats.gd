extends Node

var levelUpMenu = preload("res://UI/LevelUp.tscn")

var maxHealth : int = 1 setget setMaxHealth, getMaxHealth
var startingMaxHealth : int = 5 setget setStartingHealth
var baseSpeed : int = 200
var maxSpeed : int = 200
var playerLevel : int = 0 setget setPlayerLevel
var currentXP : int = 0 setget setCurrentXP, getCurrentXP
var strength : int = 0 setget setStr
export(float) var strRatio := 1.2
var con : int = 0 setget setCon
var conRatio : float = 1.15
var conFrictionRatio : float = 1.05
var dex : int = 0 setget setDex
var dexRatio : float = 1.075
# AttackSpeed starts at 1 and then will slowly scale down as it's multiplied by weapon attack speed
var attackSpeed : float = 1

signal noHealth
signal healthChanged(value)
signal maxHealthChanged(value)
signal currentXPChanged(newXP)
signal playerLevelChanged(newLevel)
signal addedToInventory(newItem)
signal removedFromInventory(removedItem)


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
	return 100 * playerLevel
	
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
	con = value
	var oldMaxHealth = self.maxHealth
	self.maxHealth = startingMaxHealth * pow(conRatio, con)
	self.health += self.maxHealth - oldMaxHealth
	
func setDex(value):
	dex = value
	self.attackSpeed = pow(1/dexRatio, dex)
	self.maxSpeed = self.baseSpeed * pow(dexRatio, dex)

func setPlayerLevel(newLevel):
	if playerLevel < newLevel:
		while playerLevel != newLevel:
			playerLevel += 1
			if playerLevel != 1:
				var newMenu = levelUpMenu.instance()
				newMenu.connect("upgradeChosen", self, "_emit_level_changed")
				var world = get_tree().current_scene
				world.call_deferred("add_child", newMenu)
				get_tree().paused = true
				
				
func _emit_level_changed():
	get_tree().paused = false
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
