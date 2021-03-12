extends CanvasLayer


onready var healthbar : ProgressBar = $HealthbarContainer/Healthbar
onready var stats = get_node("/root/PlayerStats")

func _ready():
	self.setHealthbarValue(stats.health / stats.getMaxHealth() * 100)
	stats.connectHealthChanged(self)
	
func setHealthbarValue(value : float):
	healthbar.value = value

func _playerstats_health_changed(value):
	self.setHealthbarValue(float(value) / stats.getMaxHealth() * 100)
