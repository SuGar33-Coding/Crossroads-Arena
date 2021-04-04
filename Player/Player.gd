extends KinematicBody2D

var dirtFx = preload("res://FX/DirtSpread.tscn")
var dashCloudFx = preload("res://FX/DashCloud.tscn")

export var Acceleration : float = 2000
export var startingFriction : float = 2000
export var dashSpeed := 500
export var dashDelay := .75

var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var dashVector := Vector2.ZERO
var floatingText = preload("res://UI/FloatingText.tscn")
var Friction : float

onready var stats = get_node("/root/PlayerStats")
onready var sprite := $Sprite
onready var attackPivot := $AttackPivot
onready var hurtbox := $Hurtbox
onready var camera := $MainCamera
onready var damagedPlayer := $DamagedPlayer
onready var dashTimer := $DashTimer
onready var movementAnimation := $MovementAnimation
onready var animationPlayer := $AnimationPlayer
onready var footstep1 := $Footstep1
onready var footstep2 := $Footstep2
onready var quickSfx := $QuickSFX
onready var longSfx := $LongSFX

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())
	
	PlayerStats.strength = 0
	PlayerStats.con = 0
	PlayerStats.dex = 0
	PlayerStats.health = PlayerStats.maxHealth
	PlayerStats.playerLevel = 1
	PlayerStats.currentXP = 0
	
	Friction = startingFriction
	stats.connect("noHealth", self, "_playerstats_no_health")
	stats.connect("playerLevelChanged", self, "_player_level_changed")
	hurtbox.connect("area_entered", self, "_hurtbox_area_entered")
	$AttackPivot/ComboTimer.connect("timeout", self, "_combo_finished")

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
		dashTimer.start(dashDelay* pow(PlayerStats.dexDashRatio, PlayerStats.dex))
		movementAnimation.play("Dashing")
		PlayerStats.resetMaxSpeed()
	elif inputVector != Vector2.ZERO:
		velocity = velocity.move_toward(inputVector * stats.maxSpeed, Acceleration * delta)
		
		if !movementAnimation.is_playing():
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

func spawnDirtFx(initVelocity = 50, lifetime = 0.4):
	var dirtFxInstance: Particles2D = dirtFx.instance()
	var newMat: ParticlesMaterial = dirtFxInstance.process_material
	newMat.initial_velocity = initVelocity
	dirtFxInstance.material = newMat
	dirtFxInstance.lifetime = lifetime
	dirtFxInstance.global_position = Vector2(self.global_position.x, self.global_position.y + 12)
	# TODO: Probably want to avoid using negative z values, maybe scale everything up?
	dirtFxInstance.z_index = -2
	dirtFxInstance.emitting = true
	get_tree().current_scene.add_child(dirtFxInstance)

func spawnDashFx():
	var dashCloudFxInstance: Particles2D = dashCloudFx.instance()
	dashCloudFxInstance.global_position = Vector2(self.global_position.x, self.global_position.y + 12)
	dashCloudFxInstance.z_index = -1
	dashCloudFxInstance.emitting = true
	get_tree().current_scene.add_child(dashCloudFxInstance)
	
func playFootstep(foot = 1):
	match foot:
		1:
			footstep1.play()
		2:
			footstep2.play()
	
func _player_level_changed(_newPlayerLevel):
	attackPivot.userStr = PlayerStats.strength
	self.Friction = self.startingFriction * pow(PlayerStats.conFrictionRatio, PlayerStats.con)

func _hurtbox_area_entered(area : Hitbox):
	var text = floatingText.instance()
	text.amount = area.damage
	add_child(text)
	
	stats.health -= area.damage
	stats.currentXP += area.damage
	camera.add_trauma(area.knockbackValue / 1000.0)
	knockback = area.getKnockbackVector(self.global_position)
	damagedPlayer.play("Damaged")
	hurtbox.startInvincibility(PlayerStats.invulnTimer)

func _playerstats_no_health():
	# When Player dies, return to main menu TODO: Change this
	#get_tree().change_scene("res://UI/StartMenu/StartMenu.tscn")
	self.remove_child(camera)
	camera.set_deferred("global_position", self.global_position)
	camera.add_trauma(2)
	var world = get_tree().current_scene
	world.add_child(camera)
	world.playerDied()
	self.queue_free()
	
func _melee_attack():
	animationPlayer.play("MeleeAttack")
	quickSfx.play()
	PlayerStats.maxSpeed *= .65
	
func _stab():
	animationPlayer.play("Stab")
	longSfx.play()
	PlayerStats.resetMaxSpeed()
	
func _parry():
	animationPlayer.play("Parry")
	PlayerStats.maxSpeed *= .65
	
func _combo_finished():
	PlayerStats.resetMaxSpeed()
