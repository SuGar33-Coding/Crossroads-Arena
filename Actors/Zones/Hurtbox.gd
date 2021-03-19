extends Area2D


export var statsPath : NodePath = "../Stats"

onready var stats : Stats = get_node(statsPath)


func _on_Hurtbox_area_entered(area):
	print("damage")
	stats.health -= 1
