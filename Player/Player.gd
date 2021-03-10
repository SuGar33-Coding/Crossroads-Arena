extends KinematicBody2D

export var MAX_SPEED = 200
export var ACCELERATION = 800
export var FRICTION = 750

const Arrow = preload("res://Weapons/Arrow.tscn")

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO


onready var sprite = $Sprite
onready var hitboxCollision = $Hitbox/hitboxCollision
onready var animationPlayer = $AnimationPlayer
onready var swipe = $Swipe
onready var stats = $Stats

func _ready():
	swipe.frame = 0

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
		animationPlayer.play("MeleeAttack")
		swipe.set_deferred("flip_h", not swipe.flip_h)
	elif Input.is_action_just_pressed("fire"):
		fireArrow()


func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.getKnockbackVector(self.global_position)
	#TODO: handle invuln

func fireArrow() -> void:
	var arrow = Arrow.instance()
	var world = get_tree().current_scene
	world.add_child(arrow)
	arrow.fire(hitboxCollision.global_position, self.global_rotation + deg2rad(-90))

func _on_Stats_noHealth():
	self.queue_free()
