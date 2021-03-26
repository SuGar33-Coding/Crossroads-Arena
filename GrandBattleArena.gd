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

#(Un)pauses a single node
func set_pause_node(node : Node, pause : bool) -> void:
	node.set_process(!pause)
	node.set_process_input(!pause)
	node.set_physics_process(!pause)
	node.set_process_internal(!pause)
	node.set_process_unhandled_input(!pause)
	node.set_process_unhandled_key_input(!pause)

#(Un)pauses a scene
#Ignored childs is an optional argument, that contains the path of nodes whose state must not be altered by the function
func set_pause_scene(rootNode : Node, pause : bool):
	set_pause_node(rootNode, pause)
	for node in rootNode.get_children():
			set_pause_scene(node, pause)
