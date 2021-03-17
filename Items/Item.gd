extends Node2D

class_name Item

onready var sprite : Sprite = $Sprite

export(String) var itemName = ""
export(int) var itemValue = 1
export(int) var effectAmount = 1
