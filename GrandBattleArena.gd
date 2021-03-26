extends Node2D

var Fighter = preload("res://Actors/Bandit/Fighter.tscn")
var Slime = preload("res://Actors/Slime/Slime.tscn")

onready var people = $YSort/People
onready var spawns = $Spawns

func _ready():
	randomize()
	spawnEnemies()

func _physics_process(_delta):
	if Input.is_action_just_pressed("openmap"):
		spawnEnemies()

func spawnEnemies():
	for spawn in spawns.get_children():
		if randi() % 3 != 0:
			var newFighter = Fighter.instance()
			newFighter.global_position = spawn.global_position + Vector2(rand_range(0, 20), rand_range(0,20))
			people.add_child(newFighter)
