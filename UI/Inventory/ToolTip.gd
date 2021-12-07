extends Popup

var statRow = preload("res://UI/Inventory/StatRow.tscn")

onready var statsContainer: VBoxContainer = $Panel/MarginContainer/StatsContainer
onready var itemNameTag: Label = $Panel/MarginContainer/StatsContainer/ItemName
onready var valueStat: StatRow = $Panel/MarginContainer/StatsContainer/ValueStat

var itemInstance: ItemInstance setget setItemInstance

func _process(delta):
	rect_position = get_global_mouse_position()

func setItemInstance(newItemInstance):
	itemInstance = newItemInstance
	itemNameTag.text = itemInstance.itemName
	
	# Every item has a value
	valueStat.statName = "Value"
	valueStat.statValue = str(itemInstance.resource.value)
	
	# Create the proper type of tooltip
	var initFunc: String
	if (itemInstance is WeaponInstance):
		initFunc = "initWeaponTooltip"
	elif (itemInstance.resource is Armor):
		initFunc = "initArmorTooltip"
	elif (itemInstance.resource is Consumable):
		initFunc = "initConsumableTooltip"
	call(initFunc, itemInstance)

func initWeaponTooltip(weaponInstance: WeaponInstance):
	addStatRow("Damage", str(weaponInstance.damage))

func initArmorTooltip(armorInstance: ItemInstance):
	var armorResource = armorInstance.resource as Armor
	addStatRow("Type", Armor.Type.keys()[armorResource.type])

func initConsumableTooltip(consumableInstance: ItemInstance):
	var consumableResource = consumableInstance.resource
	#addStatRow("Thing", consumableResource.)

func addStatRow(statName: String, statValue: String):
	var statRowInstance = statRow.instance()
	statsContainer.add_child(statRowInstance)
	statRowInstance.statName = statName
	statRowInstance.statValue = statValue
