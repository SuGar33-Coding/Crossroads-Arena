extends Control

onready var header : HBoxContainer = $Background/MarginContainer/VBoxContainer/Header
onready var strLabel : Label = $Background/MarginContainer/VBoxContainer/Header/StrHbox/StrLabel
onready var conLabel : Label = $Background/MarginContainer/VBoxContainer/Header/ConHbox/ConLabel
onready var dexLabel : Label = $Background/MarginContainer/VBoxContainer/Header/DexHbox/DexLabel

onready var attackLabel : Label = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer/AttackBox/AttackLabel
onready var dattackLabel : Label = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer/DattackBox/DattackLabel
onready var dashLabel : Label = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer/DashBox/DashLabel
onready var armorLabel : Label = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer/ArmorBox/ArmorLabel
onready var speedLabel : Label = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer/SpeedBox/SpeedLabel


var multiplierfmt = "x%.1f"
var secondsfmt = "%.1fs"
var playerNode : Player

func _ready():
	Inventory.connect("inventory_changed", self, "_updateInv")
	PlayerStats.connect("playerLevelChanged", self, "_updateStats")
	
	var world = get_tree().get_current_scene()
	playerNode = world.getPlayerNode()

	_updateDisplay()

func _updateInv(_from, _to):
	_updateDisplay()

func _updateStats(_level):
	_updateDisplay()

func _updateDisplay():
	strLabel.text = str(PlayerStats.baseStr)
	conLabel.text = str(PlayerStats.baseCon)
	dexLabel.text = str(PlayerStats.baseDex)
	
	attackLabel.text = multiplierfmt % pow(PlayerStats.strRatio, PlayerStats.baseStr)
	dattackLabel.text = multiplierfmt % pow(PlayerStats.dexAttackRatio, PlayerStats.baseDex)
	
	dashLabel.text = secondsfmt % (PlayerStats.dashDelay * pow(PlayerStats.dexDashRatio, PlayerStats.dex))
	
	armorLabel.text = str(playerNode.baseArmorValue) + "%"
	
	speedLabel.text = str(int(PlayerStats.baseSpeed * pow(PlayerStats.dexMoveRatio, PlayerStats.baseDex)))
