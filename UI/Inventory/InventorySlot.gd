class_name InventorySlot extends Panel

var ToolTipClass = preload("res://UI/Inventory/ToolTip.tscn")

var ttInstance: ToolTip

func _ready():
	self.connect("mouse_entered", self, "onMouseEntered")
	self.connect("mouse_exited", self, "onMouseExited")

# NOTE: We must use this to only handle the event once,
# the moment it's pressed
func _gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("auto_equip"):
			# TODO: This sucks so bad fix it
			var itemInstance = getPanelInventory()[getSlotName()] as ItemInstance
			if (is_instance_valid(itemInstance)):
				var slot
				# make this WAY more abstract/modular
				if itemInstance.resource is Armor:
					slot = (itemInstance.resource as Armor).type
				else:
					slot = "0"
				Inventory.swapItems(getPanelName(), getSlotName(), itemInstance.itemType, slot)
		elif Input.is_action_pressed("info") and event.button_index == BUTTON_LEFT and event.pressed:
			# quiquip TM
			print('event!')

func getSlotName() -> String:
	return get_parent().name

# abstract function uwu
func getPanelName() -> String:
	assert(false, "this is a pure abstract function; it must be implemented")
	return ""

# abstract function
func getPanelInventory() -> Dictionary:
	assert(false, "this is a pure abstract function; it must be implemented")
	return {}

func get_drag_data(_position):
	var slotName = getSlotName()
	if getPanelInventory()[slotName] != null:
		var data = {}
		data.originNode = self
		data.originPanel = getPanelName()
		data.originSlotName = slotName
		data.originResource = (getPanelInventory()[slotName] as ItemInstance).resource
		
		var dragTexture = TextureRect.new()
		dragTexture.expand = true
		dragTexture.texture = get_child(0).texture
		dragTexture.rect_size = Vector2(100, 100)
		
		var control = Control.new()
		control.add_child(dragTexture)
		dragTexture.rect_position = -0.5 * dragTexture.rect_size
		set_drag_preview(control)
		
		return data

func drop_data(_position, data):
	Inventory.swapItems(data.originPanel, data.originSlotName, getPanelName(), data.targetSlotName)

func onMouseEntered():
	if (!Inventory.isSlotEmpty(getPanelName(), getSlotName())):
		ttInstance = ToolTipClass.instance()
		add_child(ttInstance)
		ttInstance.init(getPanelInventory()[getSlotName()])

func onMouseExited():
	if (is_instance_valid(ttInstance)):
		ttInstance.queue_free()
