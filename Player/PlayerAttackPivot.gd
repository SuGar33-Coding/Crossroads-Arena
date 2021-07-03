extends AttackPivot

# Amount of time between last attack and end of combo in seconds
export var comboTime : float = 1

var comboCounter : int = 0 setget setComboCounter
var parryPos : Vector2
var chargingRanged : bool = false
var chargingTime := 0.0

# TODO: Make this a signal call
onready var animationPlayer := get_node("../AnimationPlayer")
onready var parryHitbox := $WeaponHitbox/ParryHitbox
onready var comboTimer := $ComboTimer
onready var parryTween := $ParryTween
onready var rangedFx := $RangedWeaponFX
onready var weaponFxTween := $WeaponEffects

# TODO: remove this cus it should be through inventory
onready var rangedWeapon : WeaponStats = preload("res://Weapons/BaseBow.tres")
onready var meleeWeapon : WeaponStats = weaponStats

signal meleeQuick()
signal meleeLong()
signal parry()


func _ready():
	parryPos = swordAnimDist * .75
	
	parryHitbox.connect("area_entered", self, "_parried_weapon")
	comboTimer.connect("timeout", self, "_combo_finished")
	self.connect("meleeQuick", self.get_parent(), "_melee_quick")
	self.connect("meleeLong", self.get_parent(), "_meleeLong")
	self.connect("parry", self.get_parent(), "_parry")
	

func _physics_process(delta):
	
	self.lookAtTarget(get_global_mouse_position())
	
	if chargingRanged:
		rangedFx.global_position = get_global_mouse_position()
		chargingTime += delta
	
	if not animationPlayer.is_playing():
		if Input.is_action_just_pressed("attack") and attackTimer.is_stopped():
			if backTween.is_active():
				backTween.stop_all()
				backTween.remove_all()
			
			if weaponStats.weaponType == WeaponStats.WeaponType.MELEE or weaponStats.weaponType == WeaponStats.WeaponType.SPEAR:
				var attackType: int
				if comboCounter == 0:
					# Minimum time between attacks is the time it takes to play the attack animation
					attackTimer.start(getMeleeAttackTime(0.4))
					emit_signal("meleeQuick")
					attackType = MeleeAttackType.QUICK
					comboTimer.start(comboTime*.65)
				elif comboCounter == 1:
					attackTimer.start(getMeleeAttackTime(0.75))
					emit_signal("meleeQuick")
					attackType = MeleeAttackType.QUICK
					comboTimer.start(comboTime)
				else:
					attackTimer.start(getMeleeAttackTime())
					emit_signal("meleeLong")
					attackType = MeleeAttackType.LONG
					comboTimer.stop()
					
				self.comboCounter = (self.comboCounter + 1) % 3
				
				var animLength = animationPlayer.current_animation_length
				self.startMeleeAttack(animLength, attackType)
			elif weaponStats.weaponType == WeaponStats.WeaponType.HEAVY:
				var attackDuration = animationPlayer.get_animation("MeleeAttack").length
				var attackType: int
				
				# Minimum time between attacks is the time it takes to play the attack animation
				attackTimer.start(max(weaponStats.attackSpeed * PlayerStats.attackSpeed, attackDuration))
				emit_signal("meleeQuick")
				attackType = MeleeAttackType.QUICK
				comboTimer.start(comboTime*.65)
			
				var animLength = animationPlayer.current_animation_length
				self.startMeleeAttack(animLength, attackType)
			elif weaponStats.weaponType == WeaponStats.WeaponType.RANGED:
				# Ranged weapon, enter the pull back state
				weaponFxTween.interpolate_property(rangedFx, "scale", Vector2.ONE, Vector2.ZERO, getRangedAttackTime())
				weaponFxTween.interpolate_property(rangedFx, "scale", Vector2.ZERO, Vector2.ONE, RangedProjectile.REDUCED, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, getRangedAttackTime())
				weaponFxTween.start()
				rangedFx.global_position = get_global_mouse_position()
				rangedFx.visible = true
				attackTimer.start(.5)
				PlayerStats.maxSpeed *= .5
				chargingRanged = true
				chargingTime = 0.0
				
		elif Input.is_action_just_released("attack") and chargingRanged and weaponStats.weaponType == WeaponStats.WeaponType.RANGED:
			chargingRanged = false
			rangedFx.visible = false
			PlayerStats.resetMaxSpeed()
			# To measure accuracy, we find what portion of the attack speed time they were off
			var atkSpeed = getRangedAttackTime()
			self.startRangedAttack(PlayerStats.strength, chargingTime - atkSpeed)
			
		elif Input.is_action_just_pressed("fire") and weaponStats.weaponType == WeaponStats.WeaponType.MELEE and attackTimer.is_stopped():
			emit_signal("parry")
			self.startParry()
			
		elif Input.is_action_just_pressed("swap"):
			if weaponStats.name == meleeWeapon.name:
				setWeapon(rangedWeapon)
			else:
				setWeapon(meleeWeapon)

func getMeleeAttackTime(modifier = 1.0) -> float:
	var attackDuration = animationPlayer.get_animation("MeleeAttack").length
	return max(weaponStats.attackSpeed * modifier * PlayerStats.attackSpeed, attackDuration)

func getRangedAttackTime() -> float:
	return max(weaponStats.attackSpeed * PlayerStats.attackSpeed, .5)

func startParry():
	weaponSprite.flip_h = not weaponSprite.flip_h
	weaponSprite.flip_v = not weaponSprite.flip_v
	var tweenLen = animationPlayer.current_animation_length*.5
	comboCounter = 0
	comboTimer.start(comboTime*.5)
	attackTimer.start(max(weaponStats.attackSpeed * .4 * PlayerStats.attackSpeed, comboTime*.5))
	weaponSprite.set_deferred("rotation", restingRotation)
	parryTween.interpolate_property(weaponSprite, "position", Vector2(0, 5), parryPos, tweenLen*.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	parryTween.interpolate_property(attackSignalPos, "position", attackSignalPos.position, parryPos - attackSignalPos.position, tweenLen*.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	parryTween.interpolate_property(weaponSprite, "position", parryPos, Vector2.ZERO, tweenLen, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, tweenLen)
	parryTween.interpolate_property(attackSignalPos, "position", parryPos - attackSignalPos.position, attackSignalPos.position, tweenLen, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, tweenLen)
	parryTween.start()

func setWeapon(weaponStats : WeaponStats):
	self.comboCounter = 0
	if comboTimer != null:
		comboTimer.stop()
		comboTimer.emit_signal("timeout")
	chargingRanged = false
	if rangedFx:
		rangedFx.visible = false
	.setWeapon(weaponStats)

func setComboCounter(value):
	if comboCounter < 2:
		weaponHitbox.scaleDamage(1)
		weaponHitbox.scaleKnockback(.25)
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
	
	if comboCounter < 2:
		._on_WeaponTween_tween_completed()
	elif weaponStats.weaponType == WeaponStats.WeaponType.MELEE:
		self.show_behind_parent = not self.show_behind_parent
		backTween.interpolate_property(weaponSprite, "position", weaponSprite.position, Vector2(-10, 5), self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		backTween.interpolate_property(weaponSprite, "rotation", weaponSprite.rotation, restingRotation + deg2rad(70), self.tweenLength)

		# Add the .007 so if player is spam clicking it feels more fluid/no stop on swing
		backTween.interpolate_property(weaponSprite, "position", Vector2(-10, 5), meleeRestingCoord + Vector2(5, 17), attackTimer.time_left + .007, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, self.tweenLength)
		backTween.interpolate_property(weaponSprite, "rotation", restingRotation + deg2rad(70), restingRotation + deg2rad(110), attackTimer.time_left + .007, self.tweenLength)
	elif weaponStats.weaponType == WeaponStats.WeaponType.SPEAR:
		self.show_behind_parent = not self.show_behind_parent
		backTween.interpolate_property(weaponSprite, "position", weaponSprite.position, Vector2(-10, 0), self.tweenLength, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		backTween.interpolate_property(weaponSprite, "rotation", weaponSprite.rotation, restingRotation + deg2rad(120), self.tweenLength)

		# Add the .007 so if player is spam clicking it feels more fluid/no stop on swing
		backTween.interpolate_property(weaponSprite, "position", Vector2(-10, 0), meleeRestingCoord + Vector2(5, 0), attackTimer.time_left + .007, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, self.tweenLength)
		backTween.interpolate_property(weaponSprite, "rotation", restingRotation + deg2rad(120), restingRotation + deg2rad(140), attackTimer.time_left + .007, self.tweenLength)
	backTween.start()

# Reset weapon back to its original position
func _combo_finished():
	self.comboCounter = 0
	
	if not backTween.is_active():
		backTween.interpolate_property(weaponSprite, "position", weaponSprite.position, Vector2.ZERO, .4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		backTween.interpolate_property(weaponSprite, "rotation", weaponSprite.rotation, returnRot, .4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

		backTween.start()
