extends AttackPivot

# TODO: Make this a signal call
onready var animationPlayer := get_node("../AnimationPlayer")
onready var parryHitbox := $WeaponHitbox/ParryHitbox
onready var returnTween := $ReturnTween

# TODO: remove this cus it should be through inventory
onready var rangedWeapon : WeaponStats = preload("res://Weapons/BaseBow.tres")
onready var meleeWeapon : WeaponStats = weaponStats


func _ready():
	parryHitbox.connect("area_entered", self, "_parried_weapon")

func _physics_process(_delta):
	
	self.lookAtTarget(get_global_mouse_position())
	
	if not animationPlayer.is_playing():
		if Input.is_action_just_pressed("attack") and attackTimer.is_stopped():
			attackTimer.start(weaponStats.attackSpeed * PlayerStats.attackSpeed)
			if weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
				animationPlayer.play("MeleeAttack")				
				
				var animLength = animationPlayer.current_animation_length
				self.startMeleeAttack(animLength)
			else:
				# Ranged Weapon
				self.startRangedAttack(PlayerStats.strength)
				
				
		elif Input.is_action_just_pressed("fire"):
			animationPlayer.play("Parry")
		elif Input.is_action_just_pressed("swap"):
			if weaponStats.name == meleeWeapon.name:
				setWeapon(rangedWeapon)
			else:
				setWeapon(meleeWeapon)

# Called when another parry hitbox hit's player's during parry action
func _parried_weapon(area):
	# area should be a parry hitbox
	var parriedWeapon : WeaponHitbox = area.get_parent()
	parriedWeapon.parry(weaponHitbox)
	PlayerStats.currentXP += parriedWeapon.damage



