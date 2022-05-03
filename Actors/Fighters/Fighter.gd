extends NPC

class_name Fighter

# The chance they drop their weapon if they are dropping an item
const weaponDropChance := .25

var weaponStats : WeaponInstance
var WorldItem = preload("res://Items/WorldItem.tscn")
var CoinScene = preload("res://Items/Coin.tscn")

export var rightShadowX = .5
export var leftShadowX = .5


onready var detectionZone := $DetectionZone
onready var attackPivot: AttackPivot = $AttackPivot
onready var weaponHitbox := $AttackPivot/WeaponHitbox
onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var attackTimer := $AttackPivot/AttackTimer
onready var shadowSprite := $Shadow
onready var bloodParticles := $AttackPivot/Particles2D
onready var effectsTimer := $AttackPivot/EffectsTimer

var sinX = rand_range(0, TAU)
var noise := OpenSimplexNoise.new()
var noiseY = 1
var baseColor := Color(1,1,1)
var aoeAttackPos := Vector2.ZERO
var statsResource : StatsResource
var weaponStatsResources : Array = []
var texture : Texture

# TODO: Possibly not necessary for the generic fighter class
var moveDir = 1

func init(stats : StatsResource):
	self.statsResource = stats
	self.weaponStatsResources = stats.weaponResources
	self.texture = stats.texture

func _ready():
	sprite.texture = self.texture
	stats.statsResource = self.statsResource
	randomize()
	weaponStats = weaponHitbox.weaponStats
	weaponHitbox.connect("parried", self, "_weapon_parried")
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20
	noise.persistence = .8
	moveDir = pow(-1, randi() % 2)
	movementTimer.start(rand_range(1, movementMaxTime))
	movementTimer.connect("timeout", self, "_change_direction")
	
	effectsTimer.connect("timeout", self, "_process_effects")
	
	# Set everything to default values
	animationPlayer.connect("animation_finished", self, "_anim_finished")
	animationPlayer.play("Idle")
	
	attackPivot.setUserStr(stats.strength)
	stats.connect("strChanged", self, "_strength_changed")
	
	var weaponResource : Resource = weaponStatsResources[randi() % weaponStatsResources.size()]
	weaponStats = get_node(ItemManager.createItemFromPath(weaponResource.resource_path))
	
	attackPivot.setWeapon(weaponStats)

func _physics_process(_delta):
	if state == State.CHASE and velocity.length() > 0 and not animationPlayer.is_playing():
		playMovement()
	
func lookAtTarget():
	if(detectionZone.hasTarget()):
		attackPivot.lookAtTarget(detectionZone.target.position)

func switchToChase() -> void:
	.switchToChase()
	var newTarget = detectionZone.getNewTarget()
	if newTarget != null:
		target = newTarget
	
func switchToAttack():
	animationPlayer.playback_speed = 1
	animationPlayer.play("Idle")
	.switchToAttack()
	# TODO: Make this a more well defined ratio
	attackTimer.start(weaponStats.attackSpeed * stats.attackSpeed * 2)
	if weaponStats.weaponType == WeaponStats.WeaponType.RANGED:
		animationPlayer.play("RangedAttack")
	elif weaponStats.weaponType == WeaponStats.WeaponType.AOE and is_instance_valid(target):
		# TODO: As soon as they aim, whatever starting aoe animation we have should start playing
		aoeAttackPos = detectionZone.target.global_position
		animationPlayer.play("AOEAttack")
	else:
		animationPlayer.play("MeleeWindup")
		
func startRangedAttack():
	attackPivot.startRangedAttack(stats.strength)
	
func startAOEAnimation(animLength: float):
	attackPivot.startAOEAnimation(animLength)
	
func startAOEAttack():
	attackPivot.startAOEAttack(aoeAttackPos, stats.strength)
	
func switchToStun():
	animationPlayer.playback_speed = 1
	animationPlayer.play("Idle")
	attackPivot.weaponCollision.set_deferred("disabled", true)
	.switchToStun()

func willIdle() -> bool:
	return !detectionZone.hasTarget()

func willChase() -> bool:
	return detectionZone.hasTarget()

func willAttack() -> bool:
	var distanceToTarget := 100000.0
	if detectionZone.hasTarget():
		distanceToTarget = self.global_position.distance_to(detectionZone.target.position)
	if attackTimer.is_stopped():
		if weaponStats.weaponType == WeaponStats.WeaponType.RANGED or weaponStats.weaponType == WeaponStats.WeaponType.AOE:
			return isTargetVisible and distanceToTarget <= weaponStats.projectileRange 
		else:
			return distanceToTarget <= (weaponStats.length + weaponStats.radius*2)
	else:
		return false
	
func willFlipLeft():
	if state == State.CHASE and detectionZone.hasTarget():
		return global_position.x > target.global_position.x
	else:
		return false
		
func willFlipRight():
	if state == State.CHASE and detectionZone.hasTarget():
		return global_position.x < target.global_position.x
	else:
		return false
	
func flipLeft():
	sprite.flip_h = true
	attackPivot.scale.y = -1
	shadowSprite.position.x = leftShadowX
	
func flipRight():
	sprite.flip_h = false
	attackPivot.scale.y = 1
	shadowSprite.position.x = rightShadowX
	
func findClosestAlly():
	var otherActors = get_parent().get_children()
	
	var allies = []
	for actor in otherActors:
		if(actor.is_in_group(movementGroup)):
			allies.append(actor)
	
	var minDist = 1000
	for ally in allies:
		var distance = (ally.global_position - self.global_position).length()
		if distance < minDist and ally != self:
			minDist = distance
			closestAlly = ally
		
	if minDist >= 1000:
		closestAlly = null

func returnToBaseColor():
	sprite.modulate = baseColor

func playMovement():
	animationPlayer.playback_speed = 1
	animationPlayer.play("Walk")

func playMeleeAttack():
	animationPlayer.playback_speed = 1
	animationPlayer.play("MeleeAttack")

func addEffects(effectResources : Array):
	for effectResource in effectResources:
		effectResource = effectResource as Effect
		effects.append({"effect": effectResource, "ticks": effectResource.totalTicks})

func _hurtbox_area_entered(area: Hitbox):
	# Stop any sheen
	attackPivot.weaponMat.set_shader_param("active", false)
	
	
	addEffects(area.effectResources)
	
	._hurtbox_area_entered(area)
	# Only play damaged if we're not dead
	if(stats.health >= 1):
		animationPlayer.stop(true)
		# Stun duration is scaled by knockback value
		animationPlayer.playback_speed = 350 / area.knockbackValue
		animationPlayer.play("Damaged")
	else:
		# If you die add some extra knockback
		knockback = area.getKnockbackVector(self.global_position) * 1.5
		Friction = Friction * 1.8

# Handle actor's weapon being parried by player
func _weapon_parried(area : WeaponHitbox):
	self.switchToStun()
	knockback = area.getKnockbackVector(self.global_position)
	animationPlayer.stop(true)
	animationPlayer.playback_speed = .3
	animationPlayer.play("Damaged")
	
# Chance to drop weaponStats specifically (so don't include those in the drop list
func _stats_no_health():
	self.switchToStun()
	animationPlayer.playback_speed = 1
	animationPlayer.play("Death")
	if not stats.itemDrops.empty():
		if randf() <= stats.dropChance:
			var itemInstance : ItemInstance
			
			if randf() <= self.weaponDropChance:
				itemInstance = attackPivot.weaponStats
				$AttackPivot/WeaponRestingPos/Weapon.visible = false
			else:
				itemInstance = get_node(ItemManager.createItemFromResource(((stats.itemDrops[randi() % stats.itemDrops.size()] as Item))))
	
			var worldItem = WorldItem.instance()
			worldItem.init(itemInstance, true)
			worldItem.global_position = self.global_position
			# Add it to the Ysort above the room
			self.get_parent().get_parent().call_deferred("add_child", worldItem)
	
	var maxCoins = (stats.statsResource as StatsResource).maxCoinDrop
	var minCoins = (stats.statsResource as StatsResource).minCoinDrop
	var numCoins = randi() % (maxCoins - minCoins) + minCoins
	for i in range(numCoins):
		var newCoin = CoinScene.instance()
		newCoin.global_position = self.global_position
		self.get_parent().get_parent().call_deferred("add_child", newCoin)

func _change_direction():
	moveDir *= -1
	movementTimer.start(rand_range(1, movementMaxTime))

func _strength_changed(value):
	attackPivot.setUserStr(value)

func _anim_finished(animName):
	animationPlayer.playback_speed = 1
	if animName == "Death":
		emit_signal("no_health")

func _process_effects():
	if not effects.empty():
		var totalHeal := 0
		var totalDamage := 0
		var maxPoison := 0
		var maxBleed := 0
		var isPoisoned := false
		var isBleeding := false
		var speedSlow := 0.0
		
		var removeArray = []
		
		# TODO: as of rn enemies are not effected by stat changes
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
				Effect.EffectType.SLOW:
					if effect.amount > speedSlow:
						speedSlow = effect.amount
			
			effectEntry.ticks -= 1
			
			if effectEntry.ticks <= 0:
				removeArray.append(i)
		
		totalDamage = maxBleed + maxPoison
		
		# Invert array since we went through the array in order originally
		# Avoids changing array indices while iterating through
		removeArray.invert()
		for index in removeArray:
			effects.remove(index)
		
		if isPoisoned:
			baseColor = Color(0, 1, 0)
		else:
			baseColor = Color(1,1,1)
			
		returnToBaseColor()
			
		if isBleeding:
			bloodParticles.emitting = true
			
		if totalHeal > 0:
			stats.health += totalHeal
					
			var text = floatingText.instance()
			text.amount = totalHeal
			text.isDamage = false
			add_child(text)
		if totalDamage > 0 and stats.health >= 1:
			stats.health -= totalDamage
			
			var text = floatingText.instance()
			text.amount = totalDamage
			add_child(text)
		
		self.MaxSpeed = self.baseSpeed * pow(PlayerStats.dexMoveRatio, stats.dex) * (1.0 - (speedSlow/100.0))
