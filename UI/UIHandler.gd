class_name UIHandler extends CanvasLayer

onready var pauseMenu : PauseMenu = $PauseMenu
onready var inventory : InventoryUI = $Inventory
onready var shop : ShopUI = $Shop
onready var stats : StatsUI = $Stats

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if inventory.isVisible() or shop.isVisible() or stats.isVisible():
			inventory.setVisible(false)
			shop.setVisible(false)
			stats.setVisible(false)
		else:
			pauseMenu.togglePause()
	elif Input.is_action_just_pressed("toggleInventory"):
		if not (shop.isVisible() or stats.isVisible()):
			inventory.toggleVisible()
	elif Input.is_action_just_pressed("stats"):
		if not (shop.isVisible() or inventory.isVisible()):
			stats.toggleVisible()
