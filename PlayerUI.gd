extends CanvasLayer


onready var healthbar : ProgressBar = $HealthbarContainer/Healthbar
export(NodePath) var statsPath
var stats : Stats

func _ready():
	stats = get_node(statsPath)
	
func setHealthbarValue(value : float):
	print(value)
	healthbar.value = value

func _on_Stats_healthChanged(value):
	print(value)
	print(stats.getMaxHealth())
	self.setHealthbarValue(float(value) / stats.getMaxHealth() * 100)
