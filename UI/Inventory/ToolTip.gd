class_name ToolTip extends Popup

var statRow = preload("res://UI/Inventory/StatRow.tscn")
const EffectsIconScene = preload("res://UI/EffectsUI/EffectsIcon.tscn")

onready var statsContainer: VBoxContainer = $Panel/MarginContainer/StatsContainer
onready var itemNameTag: Label = $Panel/MarginContainer/StatsContainer/ItemName
onready var valueLabel: Label = $Panel/MarginContainer/StatsContainer/HBoxContainer/ValueLabel

var itemInstance: ItemInstance setget setItemInstance
var valFmtStr = "%d"
var dmgFmtStr = "%d"
var atkSpdFmtStr = "%.1f/s"

func init(itemInstance: ItemInstance):
	self.itemInstance = itemInstance

func _process(_delta):
	rect_position = get_global_mouse_position()
	if Input.is_action_pressed("info"):
		show()
	else:
		hide()
	if !(get_parent() as CanvasItem).is_visible_in_tree():
		queue_free()

func setItemInstance(newItemInstance):
	itemInstance = newItemInstance
	itemNameTag.text = itemInstance.itemName
	var nameColor : Color = Constants.getRarityColor(itemInstance.itemRarity)
	itemNameTag.add_color_override("font_color", nameColor)
	
	# Every item has a value
	valueLabel.text = str(itemInstance.resource.value)
	
	# Create the proper type of tooltip
	# Yeah, I know Haskell
	# Don't @ me
	var initFunc: String
	if (itemInstance is WeaponInstance):
		initFunc = "initWeaponTooltip"
	elif (itemInstance.resource is Armor):
		initFunc = "initArmorTooltip"
	elif (itemInstance.resource is Consumable):
		initFunc = "initConsumableTooltip"
	call(initFunc, itemInstance)

func initWeaponTooltip(weaponInstance: WeaponInstance):
	# comparative stats
	var oldWeapon := Inventory.getWeapons()["0"] as WeaponInstance
	var hasOld = is_instance_valid(oldWeapon) and oldWeapon != weaponInstance
	addStatRow("Dmg", dmgFmtStr % weaponInstance.damage, dmgFmtStr % oldWeapon.damage if hasOld else "", true)
	addStatRow("Spd", atkSpdFmtStr % weaponInstance.attackSpeed, atkSpdFmtStr % oldWeapon.attackSpeed if hasOld else "", true)
	
	if weaponInstance.armorPierce > 0 or (hasOld and oldWeapon.armorPierce > 0):
		addStatRow("Prc", dmgFmtStr % weaponInstance.armorPierce, dmgFmtStr % oldWeapon.armorPierce if hasOld else "", true)
	
	var weaponRange = weaponInstance.length
	var oldRange = oldWeapon.length if hasOld else 0
	if weaponInstance.weaponType == WeaponStats.WeaponType.RANGED or weaponInstance.weaponType == WeaponStats.WeaponType.AOE:
		weaponRange = weaponInstance.projectileRange
	if hasOld and (oldWeapon.weaponType == WeaponStats.WeaponType.RANGED or oldWeapon.weaponType == WeaponStats.WeaponType.AOE):
		oldRange = oldWeapon.projectileRange
	
	addStatRow("Rng", dmgFmtStr % weaponRange, dmgFmtStr % oldRange if hasOld else "", true)
	
	addEffectsRow(weaponInstance.effectResources, oldWeapon.effectResources if hasOld else [])

func initArmorTooltip(armorInstance: ItemInstance):
	var armorResource = armorInstance.resource as Armor
	var oldArmorInstance := Inventory.getArmor()[armorResource.type] as ItemInstance
	var hasOld = is_instance_valid(oldArmorInstance) and oldArmorInstance != armorInstance
	var oldArmor : Armor = null
	
	if hasOld:
		oldArmor = oldArmorInstance.resource as Armor
	
	addStatRow("Type", Armor.Type.keys()[armorResource.type])
	addStatRow("Def", str(armorResource.defenseValue), str(oldArmor.defenseValue) if hasOld else "", true)
	if armorResource.speedModifier != 0:
		addStatRow("Spd", str(armorResource.speedModifier), str(oldArmor.speedModifier) if hasOld else "", true)
	
	addEffectsRow(armorResource.effects, oldArmor.effects if hasOld else [])

func initConsumableTooltip(consumableInstance: ItemInstance):
	var consumableResource = consumableInstance.resource
	addEffectsRow(consumableResource.effectResources)

func addEffectsRow(effectResources : Array, oldEffects : Array = []):
	if effectResources.size() > 0 or oldEffects.size() > 0:
		var effectRow : HBoxContainer = HBoxContainer.new()
		effectRow.alignment = effectRow.ALIGN_CENTER
		statsContainer.add_child(effectRow)
		
		for effectResource in effectResources:
			effectRow.add_child(createNewEffectIcon(effectResource))
		
		if oldEffects.size() > 0:
			var barLabel := Label.new()
			barLabel.text = "|"
			effectRow.add_child(barLabel)
			for effectResource in oldEffects:
				effectRow.add_child(createNewEffectIcon(effectResource))
		
func createNewEffectIcon(effectResource : Effect) -> EffectsIcon:
	var newEffectIcon = EffectsIconScene.instance()
	newEffectIcon.init(effectResource)
	newEffectIcon.rect_min_size = Vector2(10, 10)
	return newEffectIcon

# append a new stat row to the end of the current list of stats
func addStatRow(statName: String, statValue: String, oldStatValue: String = "", compareVals: bool = false):
	var statRowInstance = statRow.instance()
	statsContainer.add_child(statRowInstance)
	statRowInstance.statName = statName
	statRowInstance.statValue = statValue
	if oldStatValue != "":
		statRowInstance.oldValue = oldStatValue
	
	if compareVals and oldStatValue != "":
		var val = float(statValue)
		var oldVal = float(oldStatValue)
		if val > oldVal:
			statRowInstance.setCompareColor(true)
		elif val < oldVal:
			statRowInstance.setCompareColor(false)
