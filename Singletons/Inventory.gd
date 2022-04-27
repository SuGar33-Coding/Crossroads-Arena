extends Node

signal inventory_changed(from_panel, to_panel)
signal coins_changed(total_coins)

export (String) var itemDirectoryPath = "res://Items/ItemResources"
export (String) var weaponDirectoryPath = "res://Weapons"
export(Array, Resource) var shopItems = []

# TODO: Do we want different coin types?
var _inventory := {
	"bag": {
		"0": null,
		"1": null,
		"2": null,
		"3": null,
		"4": null,
		"5": null,
		"6": null,
		"7": null,
		"8": null,
		"9": null,
		"10": null,
		"11": null
	},
	"shop": {
		"0": null,
		"1": null,
		"2": null,
		"3": null,
		"4": null,
		"5": null,
		"6": null,
		"7": null,
		"8": null,
		"9": null,
		"10": null,
		"11": null
	},
	"armor": {
		Armor.Type.Head: null,
		Armor.Type.Chest: null,
		Armor.Type.Feet: null
	},
	"consumable": {
		"0": null,
		"1": null,
		"2": null,
		"3": null,
	},
	"weapon": {
		"0": null,
		"1": null
	},
}

var _coins: int = 0

func _ready():
	# on ready load in all item resources
	getItemsInDirectory(itemDirectoryPath)
	getItemsInDirectory(weaponDirectoryPath)
	
	generateShop()

func getItemsInDirectory(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name : String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				getItemsInDirectory(path+"/"+file_name)
			elif file_name.ends_with(".tres"):
				var resource := load(path+"/"+file_name)
				if resource is Item:
					shopItems.append(resource)
			file_name = dir.get_next()

func resetInventory():
	_coins = 0
	for key in _inventory.keys():
		for lowerKey in _inventory[key].keys():
			_inventory[key][lowerKey] = null
	
	generateShop()
	
	# TODO: Figure out how/when to populate the shop
	#_inventory.shop["0"] = get_node(ItemManager.createItem("res://Items/Boots.tres"))
	#for i in range(1, 10):
	#	_inventory.shop[str(i)] = get_node(ItemManager.createItem("res://Items/HealthPotion.tres"))

func generateShop():
	for i in range(12):
		var randItemResource = shopItems[randi() % shopItems.size()]
		print(randItemResource.name)
		_inventory.shop[str(i)] = get_node(ItemManager.createItemFromResource(randItemResource))
	"""for j in range(5):
		var itemArray : Array = []
		for itemRes in shopItems:
			itemRes = itemRes as Item
			if itemRes.rarity == j:
				itemArray.append(itemArray)
		for i in range(5):
			_inventory.shop[j*5 + i] = get_node(ItemManager.createItemFromResource(itemArray[randi() % itemArray.size()]))"""

func getBag() -> Dictionary:
	return _inventory.bag

func getShop() -> Dictionary:
	return _inventory.shop

func getArmor() -> Dictionary:
	return _inventory.armor

func getConsumables() -> Dictionary:
	return _inventory.consumable

func getWeapons() -> Dictionary:
	return _inventory.weapon

func getCoins() -> int:
	return _coins

func isBagFull():
	for slot in _inventory.bag.keys():
		if _inventory.bag[slot] == null:
			return false
	return true

func isSlotEmpty(panel, slot):
	return !is_instance_valid(_inventory[panel][slot])

func addItemToBag(item: ItemInstance):
	for slot in _inventory.bag.keys():
		if _inventory.bag[slot] == null:
			_inventory.bag[slot] = item
			emit_signal("inventory_changed", null, "bag")
			break

func addCoins(numCoins: int):
	_coins += numCoins
	emit_signal("coins_changed", _coins)

func buyItem(shopSlot):
	var itemToBuy : ItemInstance = Inventory.getShop()[shopSlot]
	if is_instance_valid(itemToBuy):
		addCoins(-1 * itemToBuy.value)
	
func sellItem(bagSlot):
	var itemToSell : ItemInstance = Inventory.getBag()[bagSlot]
	if is_instance_valid(itemToSell):
		addCoins(itemToSell.value)

func removeItem(panelName, panelSlot) -> ItemInstance:
	var item = _inventory[panelName][panelSlot]
	_inventory[panelName][panelSlot] = null
	
	emit_signal("inventory_changed", panelName, null)
	
	return item

func swapItems(location1, slot1, location2, slot2):
	
	# TODO: Move this somewhere else maybe but only change money with swaps involving shop
	# Due to all of the checks, only one location should ever be shop
	if location1 == 'shop':
		self.sellItem(slot2)
		self.buyItem(slot1)
	elif location2 == 'shop':
		self.sellItem(slot1)
		self.buyItem(slot2)
	
	# do da swappe
	var item1 = _inventory[location1][slot1]
	_inventory[location1][slot1] = _inventory[location2][slot2]
	_inventory[location2][slot2] = item1
	
	emit_signal("inventory_changed", location1, location2)
