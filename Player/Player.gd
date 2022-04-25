extends KinematicBody2D

var dirtFx = preload("res://FX/DirtSpread.tscn")
var dashCloudFx = preload("res://FX/DashCloud.tscn")

export var Acceleration: float = 1500
export var startingFriction: float = 750
export var baseDashSpeed := 500
export var dashDelay := .75

signal player_dashed(dashRefresh)

# TODO: Probably move dash speed to player stats
var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var dashVector := Vector2.ZERO
var dashSpeed := 500
var HitEffect = preload("res://FX/HitEffect.tscn")
var floatingText = preload("res://UI/FloatingText.tscn")
var Friction: float
var baseArmorValue : int = 0
var armorValue : int = 0
var currentArmorShred : int = 0
var currentArmorBuff : int = 0
var baseColor := Color(1,1,1)
# effects will be a list of effects resources and remaining ticks until effect goes away
var effects := []

onready var stats = get_node("/root/PlayerStats")
onready var inventory = get_node("/root/Inventory")
onready var sprite : Sprite = $Sprite
onready var headSprite := $Sprite/HeadSprite
onready var chestSprite := $Sprite/ChestSprite
onready var legSprite := $Sprite/LegSprite
onready var shadowSprite := $ShadowSprite
onready var attackPivot := $AttackPivot
onready var hurtbox := $Hurtbox
onready var camera := $MainCamera
onready var damagedPlayer := $DamagedPlayer
onready var dashTimer := $DashTimer
onready var effectsTimer := $EffectsTimer
onready var movementAnimation := $MovementAnimation
onready var animationPlayer := $AnimationPlayer
onready var footstep1 := $Footstep1
onready var footstep2 := $Footstep2
onready var bloodParticles := $BloodParticles
onready var playerUI : PlayerUI = $PlayerUI
onready var inventoryUI : InventoryUI = get_node("../../Inventory")
onready var shopUI : ShopUI = get_node("../../Shop")

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
	stats.connect("playerStrChanged", self, "_player_str_changed")
	stats.connect("playerConChanged", self, "_player_con_changed")
	hurtbox.connect("area_entered", self, "_hurtbox_area_entered")
	$AttackPivot/ComboTimer.connect("timeout", self, "_combo_finished")
	inventory.connect("inventory_changed", self, "_inventory_changed")
	effectsTimer.connect("timeout", self, "_process_effects")
	
	effectsTimer.start(1)
	
	sprite.material.set_shader_param("banner_color", stats.playerColor)
	
	dashSpeed = baseDashSpeed
	checkArmorStats()


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, Friction * delta)
	knockback = move_and_slide(knockback)

	dashVector = dashVector.move_toward(Vector2.ZERO, Acceleration * delta)
	dashVector = move_and_slide(dashVector)

	var inputVector = Vector2.ZERO

	if not (inventoryUI.isVisible() or shopUI.isVisible()):
		inputVector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		inputVector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		inputVector = inputVector.normalized()
	
	if Input.is_action_just_pressed("item"):
		var consumables := Inventory.getConsumables()
		var keys := consumables.keys()
		
		var consumableKey = null
		var consumableInstance = null
		
		for key in keys:
			if is_instance_valid(consumables[key]):
				consumableInstance = consumables[key]
				consumableKey = key
		
		if is_instance_valid(consumableInstance):
			Inventory.removeItem("consumable", consumableKey)
			var consumableResource := (consumableInstance.resource as Consumable)
			self.addEffects(consumableResource.effectResources)

	if Input.is_action_just_pressed("dash") and dashTimer.is_stopped() and not (inventoryUI.isVisible() or shopUI.isVisible()):
		# Cannot dash while aiming
		if not attackPivot.chargingRanged:
			var refreshTime = dashDelay * pow(PlayerStats.dexDashRatio, PlayerStats.dex)
			dashVector = inputVector * dashSpeed
			dashTimer.start(refreshTime)
			movementAnimation.play("Dashing")
			emit_signal("player_dashed", refreshTime)
			PlayerStats.resetMaxSpeed()
	elif inputVector != Vector2.ZERO:
		velocity = velocity.move_toward(inputVector * stats.maxSpeed, Acceleration * delta)

		if ! movementAnimation.is_playing():
			movementAnimation.play("Walking")
	else:
		movementAnimation.play("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)

	# Make sprite turn towards mouse
	var mousePos = self.get_global_mouse_position()
	if mousePos.x < global_position.x:
		sprite.flip_h = true
		headSprite.flip_h = true
		chestSprite.flip_h = true
		legSprite.flip_h = true
		shadowSprite.position.x = .5
		attackPivot.scale.y = -1
	else:
		sprite.flip_h = false
		headSprite.flip_h = false
		chestSprite.flip_h = false
		legSprite.flip_h = false
		shadowSprite.position.x = 1.25
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
	dashCloudFxInstance.global_position = Vector2(
		self.global_position.x, self.global_position.y + 12
	)
	dashCloudFxInstance.z_index = -1
	dashCloudFxInstance.emitting = true
	get_tree().current_scene.add_child(dashCloudFxInstance)


func playFootstep(foot = 1):
	match foot:
		1:
			footstep1.play()
		2:
			footstep2.play()

func checkArmorStats():
	baseArmorValue = 0
	stats.armorSpeedModifier = 1.0
	var armorDict = inventory.getArmor()
	for key in armorDict.keys():
		var itemInstance = armorDict.get(key)
		if is_instance_valid(itemInstance):
			var piece : Armor = itemInstance.resource as Armor
			match piece.type:
				Armor.Type.Head:
					headSprite.texture = piece.characterTexture
				Armor.Type.Chest:
					chestSprite.texture = piece.characterTexture
				Armor.Type.Feet:
					legSprite.texture = piece.characterTexture
			baseArmorValue += piece.defenseValue
			stats.armorSpeedModifier += piece.speedModifier
		else:
			match key:
				Armor.Type.Head:
					headSprite.texture = null
				Armor.Type.Chest:
					chestSprite.texture = null
				Armor.Type.Feet:
					legSprite.texture = null
	
	armorValue = baseArmorValue - currentArmorShred + currentArmorBuff
	
	stats.resetMaxSpeed()
	# Speed modifier affects dash speed half as much
	dashSpeed = baseDashSpeed * (1.0 + ((stats.armorSpeedModifier - 1.0)/2.0))

# Takes a list of effect resources and adds them to the player's list of effects
func addEffects(effectResources : Array):
	for effectResource in effectResources:
		effectResource = effectResource as Effect
		var hasEffect := false
		
		for effect in effects:
			var res = effect.effect
			if effectResource == res:
				effect.ticks = effectResource.totalTicks
				hasEffect = true
		
		if not hasEffect:
			effects.append({"effect": effectResource, "ticks": effectResource.totalTicks})
			playerUI.addEffect(effectResource)

func returnToBaseColor():
	sprite.modulate = baseColor

func _player_level_changed(_newPlayerLevel):
	attackPivot.userStr = PlayerStats.strength
	self.Friction = self.startingFriction * pow(PlayerStats.conFrictionRatio, PlayerStats.con)

func _player_str_changed():
	attackPivot.userStr = PlayerStats.strength
	
func _player_con_changed():
	self.Friction = self.startingFriction * pow(PlayerStats.conFrictionRatio, PlayerStats.con)

func _hurtbox_area_entered(area: Hitbox):
	var damageAmount = max(1, int(area.damage * (1 - ( max((self.armorValue - area.armorPierce), 0) /100.0))))
	
	var text = floatingText.instance()
	text.amount = damageAmount
	add_child(text)

	var hitEffect = HitEffect.instance()
	hitEffect.init(area.getSourcePos())
	add_child(hitEffect)
	
	addEffects(area.effectResources)

	if stats.health > 0:
		stats.health -= damageAmount
	stats.currentXP += damageAmount
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
	animationPlayer.play("Death")

func _inventory_changed(from_panel, to_panel):
	if(from_panel == "armor" or to_panel == "armor"):
		checkArmorStats()

func _melee_quick():
	animationPlayer.play("MeleeAttack")
	PlayerStats.maxSpeed *= .65


func _meleeLong():
	animationPlayer.play("Stab")
	_combo_finished()


func _parry():
	animationPlayer.play("Parry")
	PlayerStats.maxSpeed *= .65

func _combo_finished():
	PlayerStats.resetMaxSpeed()

func _process_effects():
	if not effects.empty():
		var totalStr = stats.baseStr
		var totalCon = stats.baseCon
		var totalDex = stats.baseDex
		var totalHeal := 0
		var totalDamage := 0
		var maxPoison := 0
		var maxBleed := 0
		var isPoisoned := false
		var isBleeding := false
		var speedSlow := 0.0
		var armorShred := 0
		var armorBuff := 0
		
		var removeArray = []
		
		for i in range(effects.size()):
			var effectEntry = effects[i]
			var effect = effectEntry.effect as Effect
			match effect.effectType:
				Effect.EffectType.HEAL:
					if effect.amount > totalHeal:
						totalHeal = effect.amount
					
				Effect.EffectType.BLEED:
					if effect.amount > maxBleed:
						maxBleed = effect.amount
					isBleeding = true
				Effect.EffectType.POISON:
					if effect.amount > maxPoison:
						maxPoison = effect.amount
					
					isPoisoned = true
				Effect.EffectType.STR:
					totalStr += effect.amount
				Effect.EffectType.CON:
					totalCon += effect.amount
				Effect.EffectType.DEX:
					totalDex += effect.amount
				Effect.EffectType.SLOW:
					if effect.amount > speedSlow:
						speedSlow = effect.amount
				Effect.EffectType.ARMOR_SHRED:
					if effect.amount > armorShred:
						armorShred = effect.amount
				Effect.EffectType.ARMOR_BUFF:
					if effect.amount > armorBuff:
						armorBuff = effect.amount
			
			effectEntry.ticks -= 1
			
			if effectEntry.ticks <= 0:
				removeArray.append(i)
		
		totalDamage = maxBleed + maxPoison
		
		# Invert array since we went through the array in order originally
		# Avoids changing array indices while iterating through
		removeArray.invert()
		for index in removeArray:
			var effectRes : Effect = effects[index].effect
			playerUI.removeEffect(effectRes)
			effects.remove(index)
		
		if isPoisoned:
			baseColor = Color(0, 1, 0)
		else:
			baseColor = Color(1,1,1)
			
		returnToBaseColor()
			
		if isBleeding:
			bloodParticles.emitting = true
			
		if stats.baseStr != totalStr or stats.strength != stats.baseStr:
			stats.strength = totalStr
			
		if stats.baseCon != totalCon or stats.con != stats.baseCon:
			stats.con = totalCon
			
		if stats.baseDex != totalDex or stats.dex != stats.baseDex:
			stats.dex = totalDex
			
		if totalHeal > 0:
			stats.health += totalHeal
					
			var text = floatingText.instance()
			text.amount = totalHeal
			text.isDamage = false
			add_child(text)
		if totalDamage > 0:
			stats.health -= totalDamage
					
			var text = floatingText.instance()
			text.amount = totalDamage
			add_child(text)
		
		# Adjust current player speed to this new modifier
		var newSpeedModifier = 1.0 - (speedSlow / 100.0)
		PlayerStats.maxSpeed = (PlayerStats.maxSpeed / PlayerStats.effectsSpeedModifier ) * newSpeedModifier
		PlayerStats.effectsSpeedModifier = newSpeedModifier
		
		currentArmorShred = armorShred
		currentArmorBuff = armorBuff
		armorValue = baseArmorValue - currentArmorShred + currentArmorBuff

