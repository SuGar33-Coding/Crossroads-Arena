extends Node2D

export (Array,Resource) var encounters
export var multiEncounterChance := 0.5 

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
var playerNearStr := false
var playerNearCon := false
var playerNearDex := false
var waveNumber := 0
var sortedEncounters := {}
var maxEncounterDifficulty := 0

onready var people := $YSort/People
onready var camera := $YSort/Player/MainCamera
onready var itemSort := $YSort/Items
onready var newWaveButtonSprite := $YSort/NewWaveButton/AnimatedSprite
onready var spawnLabel := $YSort/NewWaveButton/Label
onready var strPillarAnimation := $YSort/StrengthPillar/AnimationPlayer
onready var conPillarAnimation := $YSort/ConPillar/AnimationPlayer
onready var dexPillarAnimation := $YSort/DexPillar/AnimationPlayer
onready var strPillarLabel := $YSort/StrengthPillar/Label
onready var conPillarLabel := $YSort/ConPillar/Label
onready var dexPillarLabel := $YSort/DexPillar/Label
onready var shopUI := $Shop
var largeSpawns : Array
var medSpawns : Array
var smallSpawns : Array
var spawns : Array
	
	
func _ready():
	randomize()
	largeSpawns = $LargeSpawns.get_children()
	medSpawns = $MediumSpawns.get_children()
	smallSpawns = $SmallSpawns.get_children()
	spawns = [smallSpawns, medSpawns, largeSpawns]
	spawnLabel.visible = false
	strPillarLabel.visible = false
	conPillarLabel.visible = false
	dexPillarLabel.visible = false
	
	# TODO: Add starting weapon choices like this
	var startingItem : ItemInstance = get_node(ItemManager.createItem("res://Items/ChestPlate.tres"))
	
	var worldItem = WorldItem.instance()
	worldItem.init(startingItem)
	worldItem.global_position = newWaveButtonSprite.global_position + Vector2(30, 0)
	itemSort.add_child(worldItem)
	
	startingItem  = get_node(ItemManager.createItem("res://Weapons/BaseSword.tres"))
	
	worldItem = WorldItem.instance()
	worldItem.init(startingItem)
	worldItem.global_position = newWaveButtonSprite.global_position + Vector2(75, 0)
	itemSort.add_child(worldItem)
	
	startingItem = get_node(ItemManager.createItem("res://Weapons/BaseBow.tres"))

	worldItem = WorldItem.instance()
	worldItem.init(startingItem)
	worldItem.global_position = newWaveButtonSprite.global_position + Vector2(125, 0)
	itemSort.add_child(worldItem)
	
	# Sorted encounters will be a dictionary of dictionaries corresponding to the levels of the encounters
	# Each of these arrays will contain three arrays corresponding to each of the sizes of the encounters
	# Reminder: Decided not to sort by size because size should factor into difficulty level
	for encounter in encounters:
		if maxEncounterDifficulty < encounter.difficultyLevel:
			maxEncounterDifficulty = encounter.difficultyLevel
		if not sortedEncounters.has(encounter.difficultyLevel):
			sortedEncounters[encounter.difficultyLevel] = [] #{EncounterStats.EncounterSize.SMALL: [], EncounterStats.EncounterSize.MEDIUM: [], EncounterStats.EncounterSize.LARGE: []}
		sortedEncounters.get(encounter.difficultyLevel).append(encounter)

func _physics_process(_delta):
	if Input.is_action_just_pressed("addlevel"):
		PlayerStats.nextPlayerLevel += 1
	elif Input.is_action_just_pressed("toggleFullscreen"):
		OS.set_window_fullscreen(!OS.window_fullscreen)
		OS.set_borderless_window(!OS.window_borderless)
	elif Input.is_action_just_released("wheeldown"):
		camera.zoom.x += .25
		camera.zoom.y += .25
		camera.topLeft.position = Vector2(-1000000000, -1000000000)
		camera.bottomRight.position = Vector2(100000000, 100000000)
		camera.setLimitsToPositions()
	elif Input.is_action_just_released("wheelup"):
		camera.zoom.x -= .25
		camera.zoom.y -= .25
		
	if numEncounters <= 0:
		
		# Strength Pillar
		if PlayerStats.playerLevel < PlayerStats.nextPlayerLevel:
			if not strPillarAnimation.is_playing():
				strPillarAnimation.play("Ready")
			if not conPillarAnimation.is_playing():
				conPillarAnimation.play("Ready")
			if not dexPillarAnimation.is_playing():
				dexPillarAnimation.play("Ready")
				
			strPillarLabel.visible = playerNearStr
			conPillarLabel.visible = playerNearCon
			dexPillarLabel.visible = playerNearDex
			
			if Input.is_action_just_pressed("interact"):
				match true:
					playerNearStr:
						PlayerStats.strength += 1
						PlayerStats.incrementPlayerLevel()
						strPillarAnimation.play("ChargeUp")
						strPillarLabel.visible = false
					playerNearCon:
						PlayerStats.con += 1
						PlayerStats.incrementPlayerLevel()
						conPillarAnimation.play("ChargeUp")
						conPillarLabel.visible = false
					playerNearDex:
						PlayerStats.dex += 1
						PlayerStats.incrementPlayerLevel()
						dexPillarAnimation.play("ChargeUp")
						dexPillarLabel.visible = false
		else:
			# If we just want it to go dark on use, take out the if statements here
			if strPillarAnimation.current_animation != "ChargeUp":
				strPillarAnimation.play("Idle")
			if conPillarAnimation.current_animation != "ChargeUp":
				conPillarAnimation.play("Idle")
			if dexPillarAnimation.current_animation != "ChargeUp":
				dexPillarAnimation.play("Idle")
		
		# Wave Button
		newWaveButtonSprite.play("Ready")
		if playerNearButton:
			spawnLabel.visible = true
			if Input.is_action_just_pressed("interact"):
				spawnEnemies()
			elif Input.is_action_just_pressed("openmap"):
				shopUI.toggleVisible()
		else:
			if spawnLabel.visible == true:
				spawnLabel.visible = false
			if shopUI.isVisible():
				shopUI.toggleVisible()

func spawnEnemies():
	spawnLabel.visible = false
	
	waveNumber += 1
	
	var onLevelEncounters := []
	
	# TODO: Set up multi-encounters and different sizes
	var multiEncounterVal = randf()
	
	var selectedEncounter : EncounterStats
	# lvl 0 is for debug and will always have size small
	if sortedEncounters.has(0):
		selectedEncounter = sortedEncounters[0][randi() % sortedEncounters[0].size()]
		spawnNewEncounter(selectedEncounter)
	elif multiEncounterVal <= multiEncounterChance and sortedEncounters.has(int(waveNumber/2)):
		var difficultyNum = int(waveNumber/2)
		spawnNewEncounter(sortedEncounters[difficultyNum][randi() % sortedEncounters[difficultyNum].size()])
		spawnNewEncounter(sortedEncounters[difficultyNum][randi() % sortedEncounters[difficultyNum].size()])
	elif sortedEncounters.has(waveNumber):
		selectedEncounter = sortedEncounters[waveNumber][randi() % sortedEncounters[waveNumber].size()]
		spawnNewEncounter(selectedEncounter)
	else:
		# If we've run out of encounters, just keep spawning max level ones
		selectedEncounter = sortedEncounters[maxEncounterDifficulty][randi() % sortedEncounters[maxEncounterDifficulty].size()]
		spawnNewEncounter(selectedEncounter)

func spawnNewEncounter(encounterStats : EncounterStats):
	numEncounters += 1
	var newEncounter = Encounter.instance()
	newEncounter.init(encounterStats)
	newEncounter.connect("encounter_finished", self, "encounter_finished")
	var spawnList = spawns[newEncounter.encounterSize]
	var spawnLocation = spawnList[randi() % spawnList.size()]
	newEncounter.global_position = spawnLocation.global_position
	people.add_child(newEncounter)
	
	newWaveButtonSprite.play("Pressed") 
	strPillarAnimation.play("Idle")

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
	if numEncounters <= 0:
		strPillarAnimation.play("ChargeUp")
		conPillarAnimation.play("ChargeUp")
		dexPillarAnimation.play("ChargeUp")

func _on_NewWaveButton_body_entered(body):
	playerNearButton = true

func _on_NewWaveButton_body_exited(body):
	playerNearButton = false

func _on_StrengthPillar_body_entered(body):
	playerNearStr = true

func _on_StrengthPillar_body_exited(body):
	playerNearStr = false

func _on_ConPillar_body_entered(body):
	playerNearCon = true

func _on_ConPillar_body_exited(body):
	playerNearCon = false

func _on_DexPillar_body_entered(body):
	playerNearDex = true

func _on_DexPillar_body_exited(body):
	playerNearDex = false
