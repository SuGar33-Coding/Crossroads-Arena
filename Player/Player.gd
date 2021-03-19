extends KinematicBody2D

export var MAX_SPEED = 275
export var ACCEL = 2000
export var FRICTION = 1000

var velocity := Vector2.ZERO
var camera
var restingPosStart

onready var sprite := $Sprite
onready var pivot := $AttackPivot
onready var weapon := $AttackPivot/MeleeRestingPos/Weapon
onready var restingPos := $AttackPivot/MeleeRestingPos

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())
	restingPosStart = restingPos.position

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
		#$RestingPivot.scale.y = -1
		$AttackPivot.scale.y = -1
	else:
		sprite.flip_h = false
		#$RestingPivot.scale.y = 1
		$AttackPivot.scale.y = 1
		
	pivot.look_at(mousePos)
		
	velocity = move_and_slide(velocity)

