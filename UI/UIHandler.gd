class_name UIHandler extends CanvasLayer

onready var pauseMenu : PauseMenu = $PauseMenu
onready var inventory : InventoryUI = $Inventory
onready var shop : ShopUI = $Shop

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if inventory.isVisible() or shop.isVisible():
			inventory.setVisible(false)
			shop.setVisible(false)
		else:
			pauseMenu.togglePause()
	elif Input.is_action_just_pressed("toggleInventory"):
		if not shop.isVisible():
			inventory.toggleVisible()

