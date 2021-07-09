extends Node2D

class_name Encounter

# BIG TODO: when 2 enemies die at the same time I don't think signal is called twice so button is not reset

signal encounter_finished()

"""
Rules For Encounter Sizes:
	Small: 2-5 grunts, 0-2 special, no bosses
	Medium: 3-7 grunts, 1-4 special, 0-1 bosses
	Large: 5-12 grunts, 2-6 special, 0-2 bosses
"""
const GSPAWN_MINS = [2, 3, 5]
const GSPAWN_VAR = [4, 5, 8]
const SSPAWN_MINS = [0, 1, 2]
const SSPAWN_VAR = [3, 4, 5]
const BSPAWN_MINS = [0, 0, 0]
const BSPAWN_VAR = [1, 2, 3]

# TODO: Eventually will probably use spawn points and set pieces but for now just randomly spawn in a radius around centerpoint
const SPAWN_RANGES = [100, 160, 220]

var encounterStats : EncounterStats
var encounterSize
var numActors := 0
var numDead := 0

onready var people = get_node("../YSort/People")

# TODO: Will get level and size it should be, and should pick from large list of encounters which one to spawn
#func init(encounterLevel := 1, encounterSize : EncounterStats.EncounterSize)
func init(StatsForEncounter : EncounterStats):
	encounterStats = StatsForEncounter

# Called when the node enters the scene tree for the first time.
func _ready():	
	
	encounterSize = encounterStats.encounterSize
	var numGrunts : int = randi() % GSPAWN_VAR[encounterSize] + GSPAWN_MINS[encounterSize]
	var numSpecial : int = randi() % SSPAWN_VAR[encounterSize] + SSPAWN_MINS[encounterSize]
	var numBoss : int = randi() % BSPAWN_VAR[encounterSize] + BSPAWN_MINS[encounterSize]
	
	numActors = numGrunts + numSpecial + numBoss
	
	for i in range(numGrunts):
		var pathToActor = encounterStats.gruntFilepaths[randi() % encounterStats.gruntFilepaths.size()]
		spawnActor(pathToActor)
		
	for j in range(numSpecial):
		var pathToActor = encounterStats.specialFilepaths[randi() % encounterStats.specialFilepaths.size()]
		spawnActor(pathToActor)
		
	for k in range(numBoss):
		var pathToActor = encounterStats.commanderFilepaths[randi() % encounterStats.commanderFilepaths.size()]
		spawnActor(pathToActor)
	
	

func spawnActor(pathToActor : String):
	# Resource loader should cache resources so they are not reloaded every time
	var loadedActor = ResourceLoader.load(pathToActor)
	var newActor : NPC = loadedActor.instance()
	
	var spawnRange = SPAWN_RANGES[encounterSize]
	
	newActor.set_deferred("global_position", self.global_position + Vector2(rand_range(-1 * spawnRange, spawnRange),  rand_range(-1 * spawnRange, spawnRange)))
	newActor.connect("no_health", self, "npc_no_health")
	people.add_child(newActor)
	
func killSelf():
	emit_signal("encounter_finished")
	queue_free()
	
func npc_no_health():
	numDead += 1
	if numDead >= numActors:
		killSelf()
