class_name InventorySlot extends Panel

var tooltip = preload("res://UI/Inventory/ToolTip.tscn")

var ttInstance: Popup

func _ready():
	self.connect("mouse_entered", self, "onMouseEntered")
	self.connect("mouse_exited", self, "onMouseExited")

func _process(delta):
	if Input.is_action_pressed("info") and is_instance_valid(ttInstance):
		ttInstance.show()
	elif is_instance_valid(ttInstance):
		ttInstance.hide()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			# drop
			Inventory.removeItem(getPanelName(), getSlotName())
		elif Input.is_action_pressed("info") and event.button_index == BUTTON_LEFT and event.pressed:
			# quiquip TM
			print('event!')

func getSlotName() -> String:
	return get_parent().name

func getPanelName() -> String:
	return ""

# abstract function uwu
func getPanelInventory() -> Dictionary:
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
		ttInstance = tooltip.instance()
		# TODO: pass in the item instance
		add_child(ttInstance)

func onMouseExited():
	if (is_instance_valid(ttInstance)):
		ttInstance.queue_free()
