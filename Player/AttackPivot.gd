extends Position2D

export var swingDegrees := 80.0

onready var animationPlayer := get_node("../AnimationPlayer")
onready var weapon := $MeleeRestingPos/Weapon
onready var restingPos := $MeleeRestingPos
onready var swipe := $Swipe
onready var tween := $WeaponTween
onready var collision := $Hitbox/HitboxCollision

onready var restingRotation = weapon.rotation

var swordAnimDist

func _ready():
	swordAnimDist = collision.global_position - restingPos.global_position

func _physics_process(delta):
	
	# Make sword pivot to correct position
	var toMouse = restingPos.global_position.direction_to(get_global_mouse_position())
	
	self.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("attack"):
		swipe.set_deferred("flip_h", not swipe.flip_h)
		animationPlayer.play("MeleeAttack")
		weapon.z_index = not weapon.z_index
		var tweenLength = animationPlayer.current_animation_length/2		
		tween.interpolate_property(weapon, "position", Vector2.ZERO, swordAnimDist, tweenLength)
		var endRotation = restingRotation + deg2rad(swingDegrees) 
			
		tween.interpolate_property(weapon, "rotation", restingRotation, endRotation, tweenLength)
		
		tween.interpolate_property(weapon, "z_index", weapon.z_index, weapon.z_index, tweenLength)
		tween.start()


func _on_WeaponTween_tween_completed(object, key):
	var backTween = $BackTween
	var tweenLength = animationPlayer.current_animation_length/2
	
	backTween.interpolate_property(weapon, "position", weapon.position, Vector2.ZERO, animationPlayer.current_animation_length/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	backTween.interpolate_property(weapon, "rotation", weapon.rotation, restingRotation, tweenLength)
	backTween.start()
