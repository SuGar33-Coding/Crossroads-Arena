extends CanvasLayer


onready var healthbar : ProgressBar = $HealthbarContainer/Healthbar
onready var xpbar : ProgressBar = $HealthbarContainer/XPbar
onready var lvllabel : Label = $HealthbarContainer/LvlLabel
onready var healthbarLabel : Label = $HealthbarContainer/Healthbar/HealthbarLabel
onready var xpbarLabel : Label = $HealthbarContainer/XPbar/XPbarLabel
onready var stats = get_node("/root/PlayerStats")

func _ready():
	self.setHealthbarValue(stats.health / stats.getMaxHealth() * 100)
	stats.connectHealthChanged(self)
	stats.connect("currentXPChanged", self, "_player_xp_changed")
	stats.connect("playerLevelChanged", self, "_player_level_changed")
	
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
	
