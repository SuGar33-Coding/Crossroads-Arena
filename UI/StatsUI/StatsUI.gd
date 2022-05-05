class_name StatsUI extends CanvasLayer

onready var playerStats : PlayerStats = get_node("/root/PlayerStats")

onready var strLabel : Label = $PanelContainer/MarginContainer/HBoxContainer/AttributeContainer/AttVbox/StrHbox/StrLabel
onready var conLabel : Label = $PanelContainer/MarginContainer/HBoxContainer/AttributeContainer/AttVbox/ConHbox/ConLabel
onready var dexLabel : Label = $PanelContainer/MarginContainer/HBoxContainer/AttributeContainer/AttVbox/DexHbox/DexLabel

onready var sprite : Sprite = $PanelContainer/MarginContainer/HBoxContainer/PortraitContainer/PortraitVbox/Sprite
onready var headSprite : Sprite = $PanelContainer/MarginContainer/HBoxContainer/PortraitContainer/PortraitVbox/Sprite/HeadSprite
onready var chestSprite : Sprite = $PanelContainer/MarginContainer/HBoxContainer/PortraitContainer/PortraitVbox/Sprite/ChestSprite
onready var legSprite : Sprite = $PanelContainer/MarginContainer/HBoxContainer/PortraitContainer/PortraitVbox/Sprite/LegSprite

onready var controlNode := $PanelContainer

func _ready():
	controlNode.visible = false

func toggleVisible():
	if not controlNode.visible:
		updateStats()
	
	controlNode.visible = not controlNode.visible

func isVisible():
	return controlNode.visible

func setVisible(visible : bool):
	if visible:
		updateStats()
	
	controlNode.visible = visible

func updateStats():
	strLabel.text = str(playerStats.baseStr)
	conLabel.text = str(playerStats.baseCon)
	dexLabel.text = str(playerStats.baseDex)
	
	var world := get_tree().current_scene as Arena
	var playerNode := world.getPlayerNode()
	
	# TODO: make work
	headSprite.texture = playerNode.headSprite.texture
	chestSprite.texture = playerNode.chestSprite.texture
	legSprite.texture = playerNode.legSprite.texture
