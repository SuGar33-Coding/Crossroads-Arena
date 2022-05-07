extends Control

var cursor = preload("res://Assets/Cursor.png")

onready var playerStats = get_node("/root/PlayerStats")

func _ready():
	Inventory.resetInventory()
	Input.set_custom_mouse_cursor(cursor)

func _on_ColorPickerButton_color_changed(color):
	playerStats.playerColor = color
