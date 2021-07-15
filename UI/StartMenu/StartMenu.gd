extends Control

onready var playerStats = get_node("/root/PlayerStats")

func _on_ColorPicker_color_changed(color):
	playerStats.playerColor = color

