extends KinematicBody2D

var dirtFx = preload("res://FX/DirtSpread.tscn")

export(int) var maxPlayerHealth = 1
export(int) var startingLevel = 1
export var MaxSpeed = 275
export var Acceleration = 2000
export var Friction = 2000
export var dashSpeed := 500
export var dashDelay := .75

var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var dashVector := Vector2.ZERO

onready var stats = get_node("/root/PlayerStats")
onready var sprite := $Sprite
onready var attackPivot := $AttackPivot
onready var hurtbox := $Hurtbox
onready var camera := $MainCamera
onready var damagedPlayer := $DamagedPlayer
onready var dashTimer := $DashTimer
onready var movementAnimation := $MovementAnimation

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())
	
	stats.maxHealth = maxPlayerHealth
	stats.health = maxPlayerHealth
	stats.playerLevel = startingLevel
	stats.currentXP = 0
	stats.healthIncrease = maxPlayerHealth
	
	stats.connect("noHealth", self, "_playerstats_no_health")
	hurtbox.connect("area_entered", self, "_hurtbox_area_entered")

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, Friction * delta)
	knockback = move_and_slide(knockback)
	
	dashVector = dashVector.move_toward(Vector2.ZERO, Friction * delta)
	dashVector = move_and_slide(dashVector)
	
	var inputVector = Vector2.ZERO

	inputVector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	inputVector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	inputVector = inputVector.normalized()
	
	if Input.is_action_just_pressed("dash") and dashTimer.is_stopped():
		dashVector = inputVector * dashSpeed
		dashTimer.start(dashDelay)
	elif inputVector != Vector2.ZERO:
		velocity = velocity.move_toward(inputVector * MaxSpeed, Acceleration * delta)
		
		#spawnDirtFx()
		movementAnimation.play("Walking")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)

	# Make sprite turn towards mouse
	var mousePos = self.get_global_mouse_position()
	if mousePos.x < global_position.x:
		sprite.flip_h = true
		attackPivot.scale.y = -1
	else:
		sprite.flip_h = false
		attackPivot.scale.y = 1
		
	attackPivot.look_at(mousePos)
		
	velocity = move_and_slide(velocity)

func spawnDirtFx():
	var dirtFxInstance: Particles2D = dirtFx.instance()
	dirtFxInstance.global_position = self.global_position
	# TODO: Probably want to avoid using negative z values, maybe scale everything up?
	dirtFxInstance.z_index = -1
	dirtFxInstance.emitting = true
	get_tree().current_scene.add_child(dirtFxInstance)

func _hurtbox_area_entered(area : WeaponHitbox):
	stats.health -= area.damage
	stats.currentXP += area.damage
	camera.add_trauma(.4)
	knockback = area.getKnockbackVector(self.global_position)
	damagedPlayer.play("Damaged")

func _playerstats_no_health():
	# When Player dies, return to main menu TODO: Change this
	#get_tree().change_scene("res://UI/StartMenu/StartMenu.tscn")
	self.queue_free()
