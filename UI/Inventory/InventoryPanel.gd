class_name InventoryPanel extends Control

var tempalteBagSlot = preload("res://UI/Inventory/BagSlot.tscn")
var defaultTexture = preload("res://Assets/SmokePuff.png")

onready var gridContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
