class_name StatRow extends HBoxContainer

onready var _statLabel: Label = $Stat
onready var _valueLabel: Label = $Value
onready var _oldValueLabel: Label = $OldValue

var statName: String setget setStatName
var statValue: String setget setStatValue
var oldValue: String setget setOldValue

func _ready():
	pass

func setStatName(newStatName: String):
	statName = newStatName
	_statLabel.text = newStatName + ":"

func setStatValue(newStatValue: String):
	statValue = newStatValue
	_valueLabel.text = newStatValue
	
func setOldValue(newOldValue: String):
	oldValue = newOldValue
	_oldValueLabel.text = "| " + newOldValue
