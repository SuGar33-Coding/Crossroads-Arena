class_name PauseMenu extends CanvasLayer

onready var label := $Label
onready var quitButton := $quitGame
onready var menuButton := $MenuButton
onready var resumeButton := $ResumeButton
onready var controlLabel := $ControlsLabel
onready var controlInfo := $controlsinfo
onready var background := $ColorRect
onready var waveLabel := $WaveLabel
onready var animationPlayer := $AnimationPlayer
# TODO: be better
onready var inventoryUI : InventoryUI = get_node("../Inventory")
onready var shopUI : ShopUI = get_node("../Shop")

func _ready():
	label.visible = false
	resumeButton.connect("pressed", self, "togglePause")
	menuButton.connect("pressed", self, "togglePause")

func togglePause():
	var paused : bool = get_tree().paused
	get_tree().paused = not paused
	label.visible = not paused
	quitButton.visible = not paused
	menuButton.visible = not paused
	resumeButton.visible = not paused
	controlLabel.visible = not paused
	controlInfo.visible = not paused
	background.visible = not paused
	
	if not paused:
		background.modulate = Color(1,1,1,.3)
	else:
		background.modulate = Color(1,1,1,0)

func newWave():
	waveLabel.text = "Wave " + str(get_parent().get_parent().waveNumber)
	animationPlayer.play("NewWave")

func goToMainMenu():
	get_tree().paused = false
	get_tree().change_scene("res://UI/StartMenu/StartMenu.tscn")
