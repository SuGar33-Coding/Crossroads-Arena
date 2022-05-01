class_name ToolTip extends Popup

var statRow = preload("res://UI/Inventory/StatRow.tscn")

onready var statsContainer: VBoxContainer = $Panel/MarginContainer/StatsContainer
onready var itemNameTag: Label = $Panel/MarginContainer/StatsContainer/ItemName
onready var valueStat: StatRow = $Panel/MarginContainer/StatsContainer/ValueStat

var itemInstance: ItemInstance setget setItemInstance
var valFmtStr = "%d"
var dmgFmtStr = "%d"
var atkSpdFmtStr = "%.1f/s"

func init(itemInstance: ItemInstance):
	self.itemInstance = itemInstance

func _process(delta):
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
	var nameColor : Color = Color(Color.gray)
	match itemInstance.itemRarity:
		Item.RARITY.UBIQUITOS:
			pass
		Item.RARITY.COMMON:
			nameColor = Color(Color.whitesmoke)
		Item.RARITY.UNCOMMON:
			nameColor = Color(Color.aquamarine)
		Item.RARITY.RARE:
			nameColor = Color(Color.green)
		Item.RARITY.VERY_RARE:
			nameColor = Color(Color.blue)
		Item.RARITY.EXOTIC:
			nameColor = Color(Color.purple)
		Item.RARITY.LEGENDARY:
			nameColor = Color(Color.orange)
	itemNameTag.add_color_override("font_color", nameColor)
	
	# Every item has a value
	valueStat.statName = "Value"
	valueStat.statValue = valFmtStr % itemInstance.resource.value
	
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
	var hasOld = is_instance_valid(oldWeapon)
	addStatRow("Damage", dmgFmtStr % weaponInstance.damage, dmgFmtStr % oldWeapon.damage if hasOld else "")
	addStatRow("Speed", atkSpdFmtStr % weaponInstance.attackSpeed, atkSpdFmtStr % oldWeapon.attackSpeed if hasOld else "")

func initArmorTooltip(armorInstance: ItemInstance):
	var armorResource = armorInstance.resource as Armor
	addStatRow("Type", Armor.Type.keys()[armorResource.type])

func initConsumableTooltip(consumableInstance: ItemInstance):
	var consumableResource = consumableInstance.resource
	#addStatRow("Thing", consumableResource.)

# append a new stat row to the end of the current list of stats
func addStatRow(statName: String, statValue: String, oldStatValue: String = ""):
	var statRowInstance = statRow.instance()
	statsContainer.add_child(statRowInstance)
	statRowInstance.statName = statName
	statRowInstance.statValue = statValue
	if oldStatValue != "":
		statRowInstance.oldValue = oldStatValue
