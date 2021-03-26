extends CanvasLayer

onready var strButton = $PanelContainer/MarginContainer/HBoxContainer/StrButton
onready var conButton = $PanelContainer/MarginContainer/HBoxContainer/ConButton
onready var dexButton = $PanelContainer/MarginContainer/HBoxContainer/DexButton
onready var animationPlayer = $AnimationPlayer

signal upgradeChosen()

func _ready():
	strButton.connect("pressed", self, "_str_button_pressed")
	conButton.connect("pressed", self, "_con_button_pressed")
	dexButton.connect("pressed", self, "_dex_button_pressed")
	animationPlayer.play("FadeIn")
	
func _str_button_pressed():
	PlayerStats.strength += 1
	emit_signal("upgradeChosen")
	queue_free()
	
func _con_button_pressed():
	PlayerStats.con += 1
	emit_signal("upgradeChosen")
	queue_free()
	
func _dex_button_pressed():
	PlayerStats.dex += 1
	emit_signal("upgradeChosen")
	queue_free()

func printStats():
	print("Str: ", PlayerStats.strength)
	print("Con: ", PlayerStats.con)
	print("Dex: ", PlayerStats.dex)
	print()
