extends AttackPivot

# Amount of time between last attack and end of combo in seconds
export var comboTime : float = 1

var comboCounter : int = 0 setget setComboCounter

# TODO: Make this a signal call
onready var animationPlayer := get_node("../AnimationPlayer")
onready var parryHitbox := $WeaponHitbox/ParryHitbox
onready var comboTimer := $ComboTimer
onready var quickSfx := $QuickSFX
onready var longSfx := $LongSFX

# TODO: remove this cus it should be through inventory
onready var rangedWeapon : WeaponStats = preload("res://Weapons/BaseBow.tres")
onready var meleeWeapon : WeaponStats = weaponStats

signal meleeAttack()
signal stab()


func _ready():
	parryHitbox.connect("area_entered", self, "_parried_weapon")
	comboTimer.connect("timeout", self, "_combo_finished")
	self.connect("meleeAttack", self.get_parent(), "_melee_attack")
	self.connect("stab", self.get_parent(), "_stab")
	

func _physics_process(_delta):
	
	self.lookAtTarget(get_global_mouse_position())
	
	if not animationPlayer.is_playing():
		if Input.is_action_just_pressed("attack") and attackTimer.is_stopped():
			var timerAmount
			if weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
				if backTween.is_active():
					backTween.stop_all()
					backTween.remove_all()
				
				if comboCounter == 0:
					# Minimum time between attacks is the time it takes to play the attack animation
					attackTimer.start(max(weaponStats.attackSpeed * .4 * PlayerStats.attackSpeed, .1))
					emit_signal("meleeAttack")
					comboTimer.start(comboTime)
					quickSfx.play()
				elif comboCounter == 1:
					attackTimer.start(max(weaponStats.attackSpeed * .75 * PlayerStats.attackSpeed, .1))
					emit_signal("meleeAttack")
					comboTimer.start(comboTime)
					quickSfx.play()
				else:
					attackTimer.start(max(weaponStats.attackSpeed * PlayerStats.attackSpeed, .2))
					emit_signal("stab")
					comboTimer.stop()
					longSfx.play()
					
				
				self.comboCounter = (self.comboCounter + 1) % 3
				
				
				var animLength = animationPlayer.current_animation_length
				self.startMeleeAttack(animLength)

			else:
				attackTimer.start(weaponStats.attackSpeed * PlayerStats.attackSpeed)
				# Ranged Weapon
				self.startRangedAttack(PlayerStats.strength)
				
				
		elif Input.is_action_just_pressed("fire"):
			animationPlayer.play("Parry")
		elif Input.is_action_just_pressed("swap"):
			self.comboCounter = 0
			if weaponStats.name == meleeWeapon.name:
				setWeapon(rangedWeapon)
			else:
				setWeapon(meleeWeapon)

func setWeapon(weaponStats : WeaponStats):
	if comboTimer != null:
		comboTimer.stop()
		comboTimer.emit_signal("timeout")
	.setWeapon(weaponStats)

func setComboCounter(value):
	if comboCounter < 2:
		weaponHitbox.scaleDamage(1)
		weaponHitbox.scaleKnockback(.5)
	else:
		weaponHitbox.scaleDamage(2)
		weaponHitbox.scaleKnockback(1)
	comboCounter = value

# Called when another parry hitbox hit's player's during parry action
func _parried_weapon(area):
	# area should be a parry hitbox
	var parriedWeapon : WeaponHitbox = area.get_parent()
	parriedWeapon.parry(weaponHitbox)
	PlayerStats.currentXP += parriedWeapon.damage

func _on_WeaponTween_tween_completed():
	self.show_behind_parent = not self.show_behind_parent
	
	
	if comboCounter < 2:
		backTween.interpolate_property(weapon, "position", weapon.position, Vector2(-20, 5), self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		backTween.interpolate_property(weapon, "rotation", weapon.rotation, restingRotation - deg2rad(50), self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN)

		# Add the .007 so if player is spam clicking it feels more fluid/no stop on swing
		backTween.interpolate_property(weapon, "position", Vector2(-20, 5), Vector2.ZERO, attackTimer.time_left + .007, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, self.tweenLength)
		backTween.interpolate_property(weapon, "rotation", restingRotation - deg2rad(50), restingRotation, attackTimer.time_left + .007, Tween.TRANS_LINEAR, Tween.EASE_IN, self.tweenLength)

	else:
		backTween.interpolate_property(weapon, "position", weapon.position, Vector2(-10, 5), self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		backTween.interpolate_property(weapon, "rotation", weapon.rotation, restingRotation + deg2rad(70), self.tweenLength)

		# Add the .007 so if player is spam clicking it feels more fluid/no stop on swing
		backTween.interpolate_property(weapon, "position", Vector2(-10, 5), Vector2(5, 7), attackTimer.time_left + .007, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, self.tweenLength)
		backTween.interpolate_property(weapon, "rotation", restingRotation + deg2rad(70), restingRotation + deg2rad(110), attackTimer.time_left + .007, self.tweenLength)

	backTween.start()

# Reset weapon back to its original position
func _combo_finished():
	self.comboCounter = 0
	
	backTween.interpolate_property(weapon, "position", weapon.position, Vector2.ZERO, .4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	backTween.interpolate_property(weapon, "rotation", weapon.rotation, restingRotation, .4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	backTween.start()
