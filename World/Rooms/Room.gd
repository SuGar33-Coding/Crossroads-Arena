extends Node2D

class_name Room

const Zombie = preload("res://Actors/Zombie/Zombie.tscn")
const Shanker = preload("res://Actors/Shanker/Shanker.tscn")
const Ranger = preload("res://Actors/Ranger/Ranger.tscn")

onready var spawnPoints = $SpawnPoints

# Coordinates of the room in the world
var row : int
var col : int

func _ready():
	randomize()
	for spawnPoint in spawnPoints.get_children():
		var r = randi() % 2
		if r == 0:
			var enemyType = randi() % 3
			var enemy : KinematicBody2D
			match enemyType:
				0:
					enemy = Zombie.instance()
				1:
					enemy = Ranger.instance()
				2:
					enemy = Shanker.instance()
					
			enemy.global_position = spawnPoint.global_position
			self.add_child(enemy)

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
#func set_pause_scene(rootNode : Node, pause : bool, ignoredChilds : PoolStringArray = [null]):
#	set_pause_node(rootNode, pause)
#	for node in rootNode.get_children():
#		if not (String(node.get_path()) in ignoredChilds):
#			set_pause_scene(node, pause, ignoredChilds)
			
func pauseRoom():
	set_pause_scene(self, true)
	
func unpauseRoom():
	set_pause_scene(self, false)
	
func _player_entered(body):
	unpauseRoom()
	
func _player_exited(body):
	pauseRoom()
