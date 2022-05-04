class_name Arena extends Node2D

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
var playerNearShop := false
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
onready var strParticles := $YSort/StrengthPillar/Particles2D
onready var conPillarAnimation := $YSort/ConPillar/AnimationPlayer
onready var conParticles := $YSort/ConPillar/Particles2D
onready var dexPillarAnimation := $YSort/DexPillar/AnimationPlayer
onready var dexParticles := $YSort/DexPillar/Particles2D
onready var strPillarLabel := $YSort/StrengthPillar/Label
onready var conPillarLabel := $YSort/ConPillar/Label
onready var dexPillarLabel := $YSort/DexPillar/Label
onready var shopUI := $UIHandler/Shop
onready var shopkeep : ShopKeep = $YSort/ShopKeep
onready var scenery : YSort = $YSort/Scenery
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
	
	shopkeep.connect("body_entered", self, "_player_entered_shopkeep")
	shopkeep.connect("body_exited", self, "_player_exited_shopkeep")
	
	#generateVegetation()
	
	# TODO: Add starting weapon choices like this
	var startingItem : ItemInstance = get_node(ItemManager.createItemFromPath("res://Items/ItemResources/ChestPlate.tres"))
	
	var worldItem = WorldItem.instance()
	worldItem.init(startingItem)
	worldItem.global_position = newWaveButtonSprite.global_position + Vector2(30, 0)
	itemSort.add_child(worldItem)
	
	startingItem  = get_node(ItemManager.createItemFromPath("res://Weapons/BaseSword.tres"))
	
	worldItem = WorldItem.instance()
	worldItem.init(startingItem)
	worldItem.global_position = newWaveButtonSprite.global_position + Vector2(75, 0)
	itemSort.add_child(worldItem)
	
	startingItem = get_node(ItemManager.createItemFromPath("res://Weapons/BaseBow.tres"))

	worldItem = WorldItem.instance()
	worldItem.init(startingItem)
	worldItem.global_position = newWaveButtonSprite.global_position + Vector2(125, 0)
	itemSort.add_child(worldItem)
	
	startingItem = get_node(ItemManager.createItemFromPath("res://Items/ItemResources/HealthPotion.tres"))

	worldItem = WorldItem.instance()
	worldItem.init(startingItem)
	worldItem.global_position = newWaveButtonSprite.global_position + Vector2(75, 75)
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
				strPillarAnimation.play("ChargeUp")
			if not conPillarAnimation.is_playing():
				conPillarAnimation.play("ChargeUp")
			if not dexPillarAnimation.is_playing():
				dexPillarAnimation.play("ChargeUp")
				
			strPillarLabel.visible = playerNearStr
			conPillarLabel.visible = playerNearCon
			dexPillarLabel.visible = playerNearDex
			
			if Input.is_action_just_pressed("interact"):
				match true:
					playerNearStr:
						PlayerStats.baseStr += 1
						PlayerStats.incrementPlayerLevel()
						strPillarAnimation.play("Chosen")
						strPillarLabel.visible = false
						camera.add_trauma(.5)
						strParticles.emitting = true
					playerNearCon:
						PlayerStats.baseCon += 1
						PlayerStats.incrementPlayerLevel()
						conPillarAnimation.play("Chosen")
						conPillarLabel.visible = false
						conParticles.emitting = true
						camera.add_trauma(.5)
					playerNearDex:
						PlayerStats.baseDex += 1
						PlayerStats.incrementPlayerLevel()
						dexPillarAnimation.play("Chosen")
						dexPillarLabel.visible = false
						dexParticles.emitting = true
						camera.add_trauma(.5)
		else:
			# If we just want it to go dark on use, take out the if statements here
			strPillarAnimation.play("Idle")
			conPillarAnimation.play("Idle")
			dexPillarAnimation.play("Idle")
		
		# Wave Button
		newWaveButtonSprite.play("Ready")
		if playerNearButton:
			spawnLabel.visible = true
			if Input.is_action_just_pressed("interact"):
				spawnEnemies()
		elif spawnLabel.visible == true:
			spawnLabel.visible = false
		
		if playerNearShop:
			if Input.is_action_just_pressed("openShop"):
				shopUI.toggleVisible()
		elif shopUI.isVisible():
			shopUI.toggleVisible()

func playPillarReadies():
	strPillarAnimation.play("Ready")
	conPillarAnimation.play("Ready")
	dexPillarAnimation.play("Ready")

func stopPillarExplosion():
	strParticles.emitting = false
	conParticles.emitting = false
	dexParticles.emitting = false

func generateVegetation():
	var vegetationScenes := []
	
	var path = "res://World/Scenery/"
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name : String = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var resource := load(path+"/"+file_name)
				vegetationScenes.append(resource)
			file_name = dir.get_next()
	
	print(camera.limit_right)
	print(camera.limit_left)
	
	print(camera.limit_bottom)
	print(camera.limit_top)
	var xRange := int(camera.limit_right - camera.limit_left)
	var yRange := int(camera.limit_bottom - camera.limit_top)
	for i in range(100):
		var xpos = randi() % xRange + camera.limit_left
		var ypos = randi() % yRange + camera.limit_top
		var pos := Vector2(xpos, ypos)
		var instance = vegetationScenes[randi() % vegetationScenes.size()].instance() as WorldSpawn
		
		scenery.add_child(instance)
		instance.global_position = pos
		instance.checkWalls()

func spawnEnemies():
	spawnLabel.visible = false
	shopkeep.setAvailable(false)
	
	waveNumber += 1
	$UIHandler.newWave()
	
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
	var sceneChangerPlayer = $UIHandler/PauseMenu/AnimationPlayer
	sceneChangerPlayer.play("SceneChange")
	sceneChangerPlayer.connect("animation_finished", self, "goToMainMenu")
	
func goToMainMenu(_stuff):
	get_tree().paused = false
	get_tree().change_scene("res://UI/StartMenu/StartMenu.tscn")

func getPlayerNode() -> Player:
	return get_node("./YSort/Player") as Player

func encounter_finished():
	numEncounters -= 1
	if numEncounters <= 0:
		strPillarAnimation.play("ChargeUp")
		conPillarAnimation.play("ChargeUp")
		dexPillarAnimation.play("ChargeUp")
		shopkeep.setAvailable(true)
		Inventory.generateShop()

func _on_NewWaveButton_body_entered(_body):
	playerNearButton = true

func _on_NewWaveButton_body_exited(_body):
	playerNearButton = false

func _on_StrengthPillar_body_entered(_body):
	playerNearStr = true

func _on_StrengthPillar_body_exited(_body):
	playerNearStr = false

func _on_ConPillar_body_entered(_body):
	playerNearCon = true

func _on_ConPillar_body_exited(_body):
	playerNearCon = false

func _on_DexPillar_body_entered(_body):
	playerNearDex = true

func _on_DexPillar_body_exited(_body):
	playerNearDex = false

func _player_entered_shopkeep(_body):
	playerNearShop = true

func _player_exited_shopkeep(_body):
	playerNearShop = false
