extends CanvasLayer


onready var healthbar : ProgressBar = $HBoxContainer/VBoxContainer/HealthbarContainer/Healthbar
onready var xpbar : ProgressBar = $HBoxContainer/VBoxContainer/HBoxContainer/XPbar
onready var lvllabel : Label = $HBoxContainer/VBoxContainer/HBoxContainer/LvlLabel
onready var healthbarLabel : Label = $HBoxContainer/VBoxContainer/HealthbarContainer/Healthbar/HealthbarLabel
onready var xpbarLabel : Label = $HBoxContainer/VBoxContainer/HBoxContainer/XPbar/XPbarLabel
onready var potLabel : Label = $HBoxContainer/PanelContainer/HBoxContainer/PotLabel
onready var stats = get_node("/root/PlayerStats")

func _ready():
	self.setHealthbarValue(stats.health / stats.getMaxHealth() * 100)
	stats.connectHealthChanged(self)
	stats.connect("currentXPChanged", self, "_player_xp_changed")
	stats.connect("playerLevelChanged", self, "_player_level_changed")
	stats.connect("addedToInventory", self, "_item_added_to_inv")
	stats.connect("removedFromInventory", self, "_item_removed_from_inv")
	
func setHealthbarValue(value : float):
	healthbar.value = value

func setXPbarValue(value : float):
	xpbar.value = value

func _playerstats_health_changed(value):
	self.setHealthbarValue(float(value) / stats.getMaxHealth() * 100)
	healthbarLabel.text = str(value) + " / " + str(stats.getMaxHealth())

func _player_xp_changed(newXP):
	self.setXPbarValue(float(newXP) / stats.xpToNextLevel() * 100)
	xpbarLabel.text = str(int(newXP)) + " / " + str(stats.xpToNextLevel())
	
func _player_level_changed(newLevel):
	lvllabel.text = "Lvl: " + str(stats.playerLevel)
	
func _item_added_to_inv(newItem):
	if newItem is HealthPotion:
		potLabel.text = str(PlayerStats.getNumItemsOfType("HealthPotion"))

func _item_removed_from_inv(removedItem):
	if removedItem is HealthPotion:
		potLabel.text = str(PlayerStats.getNumItemsOfType("HealthPotion"))
