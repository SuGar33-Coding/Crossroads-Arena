extends AttackPivot

# TODO: Make this a signal call
onready var animationPlayer := get_node("../AnimationPlayer")
onready var parryHitbox := $WeaponHitbox/ParryHitbox
onready var attackTimer := $AttackTimer

func _ready():
	parryHitbox.connect("area_entered", self, "_parried_weapon")
	weaponHitbox.connect("area_entered", self, "_damaged_enemy")

func _physics_process(_delta):
	
	self.lookAtTarget(get_global_mouse_position())
	
	if not animationPlayer.is_playing():
		if Input.is_action_just_pressed("attack") and attackTimer.is_stopped():
			animationPlayer.play("MeleeAttack")
			attackTimer.start(weaponStats.attackSpeed * PlayerStats.attackSpeed)
			
			var animLength = animationPlayer.current_animation_length
			self.startAttack(animLength)
		elif Input.is_action_just_pressed("fire"):
			animationPlayer.play("Parry")

# Called when another parry hitbox hit's player's during parry action
func _parried_weapon(area):
	# area should be a parry hitbox
	var parriedWeapon : WeaponHitbox = area.get_parent()
	parriedWeapon.parry(weaponHitbox)
	PlayerStats.currentXP += parriedWeapon.damage

# Player gains xp for the damage they do to each enemy
func _damaged_enemy(_area):
	PlayerStats.currentXP += weaponHitbox.damage
