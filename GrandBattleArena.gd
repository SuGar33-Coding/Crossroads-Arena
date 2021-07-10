extends Node2D

export (Array,Resource) var encounters 

var Fighter = preload("res://Actors/Fighters/Bandit/Bandit.tscn")
var Slime = preload("res://Actors/Slime/Slime.tscn")
var Brute = preload("res://Actors/Brute/Brute.tscn")
var ChaosKnight = preload("res://Actors/Fighters/ChaosKnight/ChaosKnight.tscn")
var Rogue = preload("res://Actors/Dashers/Rogue/Rogue.tscn")
var Charger = preload("res://Actors/Chargers/Charger/Charger.tscn")
var Ranger = preload("res://Actors/Fighters/Ranger/Ranger.tscn")
var Mage = preload("res://Actors/Fighters/Mage/Mage.tscn")
var Encounter = preload("res://World/Encounters/Encounter.tscn")
var WorldItem = preload("res://Items/WorldItem.tscn")
var numEncounters := 0
var playerNearButton := false
var waveNumber := 0
var sortedEncounters := {}

onready var people := $YSort/People
onready var camera := $YSort/Player/MainCamera
onready var itemSort := $YSort/Items
onready var newWaveButtonSprite := $YSort/NewWaveButton/AnimatedSprite
var largeSpawns : Array
var medSpawns : Array
var smallSpawns : Array

	
	
func _ready():
	randomize()
	largeSpawns = $LargeSpawns.get_children()
	medSpawns = $MediumSpawns.get_children()
	smallSpawns = $SmallSpawns.get_children()
	
	# TODO: Add starting weapon choices like this
	var startingItem : ItemInstance = get_node(ItemManager.createItem("res://Items/Shoes.tres"))
	
	var worldItem = WorldItem.instance()
	worldItem.init(startingItem)
	worldItem.global_position = newWaveButtonSprite.global_position + Vector2(30, 0)
	itemSort.add_child(worldItem)
	
	# Sorted encounters will be a dictionary of dictionaries corresponding to the levels of the encounters
	# Each of these arrays will contain three arrays corresponding to each of the sizes of the encounters
	for encounter in encounters:
		if not sortedEncounters.has(encounter.difficultyLevel):
			sortedEncounters[encounter.difficultyLevel] = {0: [], 1: [], 2: []}
		sortedEncounters.get(encounter.difficultyLevel)[encounter.encounterSize].append(encounter)

func _physics_process(_delta):
	if Input.is_action_just_pressed("addlevel"):
		PlayerStats.playerLevel += 1
	elif Input.is_action_just_pressed("toggleFullscreen"):
		OS.set_window_fullscreen(!OS.window_fullscreen)
		OS.set_borderless_window(!OS.window_borderless)
	elif Input.is_action_just_released("wheeldown"):
		camera.zoom.x += .25
		camera.zoom.y += .25
		camera.topLeft.position = Vector2(-1000000000, -1000000000)
		camera.bottomRight.position = Vector2(100000000, 100000000)
		camera.setLimitsToPositions()
		
	if numEncounters <= 0:
		newWaveButtonSprite.play("Ready")
		if playerNearButton:
			if Input.is_action_just_pressed("openmap"):
				spawnEnemies()
				

func spawnEnemies():
	waveNumber += 1
	
	var onLevelEncounters := []
	
	# TODO: Set up multi-encounters and different sizes
	
	var selectedEncounter : EncounterStats
	if sortedEncounters.has(0):
		selectedEncounter = sortedEncounters[0][0][randi() % sortedEncounters[waveNumber][1].size()]
	elif sortedEncounters.has(waveNumber):
		selectedEncounter = sortedEncounters[waveNumber][1][randi() % sortedEncounters[waveNumber][1].size()]
	else:
		selectedEncounter = sortedEncounters[1][1][randi() % sortedEncounters[1][1].size()]
	
	numEncounters = 1
	
	var newEncounter = Encounter.instance()
	newEncounter.init(selectedEncounter)
	newEncounter.connect("encounter_finished", self, "encounter_finished")
	var spawnLocation = smallSpawns[randi() % smallSpawns.size()]
	newEncounter.global_position = spawnLocation.global_position
	self.add_child(newEncounter)
	
	newWaveButtonSprite.play("Pressed") 

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

func playerDied():
	var sceneChangerPlayer = $CanvasLayer/AnimationPlayer
	sceneChangerPlayer.play("SceneChange")
	sceneChangerPlayer.connect("animation_finished", self, "goToMainMenu")
	
func goToMainMenu(_stuff):
	get_tree().paused = false
	get_tree().change_scene("res://UI/StartMenu/StartMenu.tscn")

func encounter_finished():
	numEncounters -= 1

func _on_NewWaveButton_body_entered(body):
	playerNearButton = true

func _on_NewWaveButton_body_exited(body):
	playerNearButton = false
