extends KinematicBody2D

export(int) var maxPlayerHealth = 1
export(int) var startingLevel = 1
export var MAX_SPEED = 275
export var ACCEL = 2000
export var FRICTION = 1000

var velocity := Vector2.ZERO
var restingPosStart

onready var stats = get_node("/root/PlayerStats")
onready var sprite := $Sprite
onready var pivot := $AttackPivot
onready var weapon := $AttackPivot/MeleeRestingPos/Weapon
onready var restingPos := $AttackPivot/MeleeRestingPos
onready var hurtbox := $Hurtbox
onready var camera := $MainCamera

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())
	restingPosStart = restingPos.position
	
	stats.maxHealth = maxPlayerHealth
	stats.health = maxPlayerHealth
	stats.playerLevel = startingLevel
	stats.currentXP = 0
	stats.healthIncrease = maxPlayerHealth
	
	stats.connect("noHealth", self, "_playerstats_no_health")
	hurtbox.connect("area_entered", self, "_hurtbox_area_entered")

func _physics_process(delta):	
	
	var inputVector = Vector2.ZERO

	inputVector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	inputVector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	inputVector = inputVector.normalized()

	if inputVector != Vector2.ZERO:
		velocity = velocity.move_toward(inputVector * MAX_SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Make sprite turn towards mouse
	var mousePos = self.get_global_mouse_position()
	if mousePos.x < global_position.x:
		sprite.flip_h = true
		$AttackPivot.scale.y = -1
	else:
		sprite.flip_h = false
		$AttackPivot.scale.y = 1
		
	pivot.look_at(mousePos)
		
	velocity = move_and_slide(velocity)

func _hurtbox_area_entered(area : WeaponHitbox):
	stats.health -= area.damage
	stats.currentXP += area.damage
	camera.add_trauma(.4)

func _playerstats_no_health():
	# When Player dies, return to main menu TODO: Change this
	#get_tree().change_scene("res://UI/StartMenu/StartMenu.tscn")
	self.queue_free()
