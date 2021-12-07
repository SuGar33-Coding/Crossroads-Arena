class_name StatRow extends HBoxContainer

onready var _statLabel: Label = $Stat
onready var _valueLabel: Label = $Value

var statName: String setget setStatName
var statValue: String setget setStatValue

func _ready():
	pass

func setStatName(newStatName: String):
	statName = newStatName
	_statLabel.text = newStatName + ":"

func setStatValue(newStatValue: String):
	statValue = newStatValue
	_valueLabel.text = newStatValue
