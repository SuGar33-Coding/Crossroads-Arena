extends KinematicBody2D

export(int) var maxPlayerHealth = 1
export(int) var startingLevel = 1
export var MAX_SPEED = 200
export var ACCELERATION = 800
export var FRICTION = 750

const Arrow = preload("res://Weapons/Arrow.tscn")

var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var recentlyAttacked := false
var camera : MainCamera


onready var sprite = $Sprite
onready var hitboxCollision = $Hitbox/hitboxCollision
onready var animationPlayer = $AnimationPlayer
onready var swipe = $Swipe
onready var stats = get_node("/root/PlayerStats")
onready var attackTimer = $AttackTimer
onready var meleeEffect = $MeleeEffect
onready var rangedEffect = $RangedEffect
onready var dmgEffect = $DmgEffect

func _ready():
	stats.maxHealth = maxPlayerHealth
	stats.health = maxPlayerHealth
	stats.playerLevel = startingLevel
	stats.currentXP = 0
	stats.healthIncrease = maxPlayerHealth
	swipe.frame = 0
	stats.connectNoHealth(self)
	
	camera = get_node("../MainCamera")

func _physics_process(delta):	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	self.look_at(self.get_global_mouse_position())
	self.rotate(deg2rad(90))
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("attack"):
		if not recentlyAttacked:
			recentlyAttacked = true
			attackTimer.start(PlayerStats.attackSpeed)
			animationPlayer.play("MeleeAttack")
			meleeEffect.play()
			swipe.set_deferred("flip_h", not swipe.flip_h)
	elif Input.is_action_just_pressed("fire"):
		if not recentlyAttacked:
			recentlyAttacked = true
			rangedEffect.play()
			attackTimer.start(PlayerStats.attackSpeed)
			fireArrow()
	elif Input.is_action_just_pressed("use_pot"):
		if stats.getNumItemsOfType("HealthPotion") > 0 and stats.health < stats.maxHealth:
			var healthPot = stats.getItemOfType("HealthPotion")
			healthPot.usePot()


func _on_hurtbox_area_entered(area):
	dmgEffect.play() 
	stats.health -= area.damage
	stats.currentXP += area.damage
	knockback = area.getKnockbackVector(self.global_position)
	camera.add_trauma(.4)
	#TODO: handle invuln

func fireArrow() -> void:
	var arrow = Arrow.instance()
	var world = get_tree().current_scene
	# Have to set it before you add it as a child otherwise the room area's think you are exiting them
	arrow.global_position = hitboxCollision.global_position
	world.add_child(arrow)
	arrow.fire(hitboxCollision.global_position, self.global_rotation + deg2rad(-90), true)
	

func _playerstats_no_health():
	# When Player dies, return to main menu TODO: Change this
	get_tree().change_scene("res://UI/StartMenu/StartMenu.tscn")
	self.queue_free()

func _on_AttackTimer_timeout():
	recentlyAttacked = false
