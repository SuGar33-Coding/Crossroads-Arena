extends CanvasLayer

var emptyImage := preload("res://Assets/Wall.png")
var currentRoomBorder: StyleBoxFlat = preload("res://UI/CurrentRoomBorder.tres")
var roomBorder: StyleBoxFlat = preload("res://UI/RoomBorder.tres")

var roomTypes := []
var roomTextures := []
var rectScale := Vector2(0,0)
var roomPanel: PanelContainer
var currentHighlighted: PanelContainer setget setCurrentHighlighted
export(float) var overlayOpacity := .4

onready var gridContainer := $GridContainer

func generateMapOverlay(roomTypeArray : Array):
	roomTypes = roomTypeArray
	gridContainer.columns = len(roomTypes[0])
	gridContainer.modulate = Color(1,1,1,overlayOpacity)
	
	for row in range(len(roomTypes)):
		roomTextures.append([])
		for col in range(gridContainer.columns):
			var textureRect = TextureRect.new()
			if(roomTypes[row][col] != 0):
				textureRect.texture = emptyImage
			textureRect.size_flags_horizontal = textureRect.SIZE_EXPAND_FILL
			textureRect.size_flags_vertical = textureRect.SIZE_EXPAND_FILL
			textureRect.modulate = Color(0,0,0)
			textureRect.expand = true
			textureRect.rect_min_size = rectScale
			
			roomPanel = PanelContainer.new()
			roomPanel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			roomPanel.size_flags_vertical = Control.SIZE_EXPAND_FILL
			if (roomTypes[row][col] == 0):
				roomPanel.modulate = Color(0,0,0,0)
			roomPanel.add_stylebox_override("panel", roomBorder)
			
			roomPanel.add_child(textureRect)
			
			roomTextures[row].append(textureRect)
			
			gridContainer.add_child(roomPanel)
	
func roomDiscovered(row : int, col : int):
	var roomTexture = roomTextures[row][col]
	
	match roomTypes[row][col]:
		1:
			roomTexture.modulate = Color("#5c7072")
		2:
			roomTexture.modulate = Color("#8a6262")
		3:
			roomTexture.modulate = Color("#8a826a")
		4:
			roomTexture.modulate = Color("#7e5f8c")

func setCurrentRoom(row: int, col: int):
	var roomTexture: TextureRect = roomTextures[row][col]
	self.currentHighlighted = roomTexture.get_parent()
	
func setCurrentHighlighted(room: PanelContainer):
	if currentHighlighted != null:
		currentHighlighted.add_stylebox_override("panel", roomBorder)
	currentHighlighted = room
	currentHighlighted.add_stylebox_override("panel", currentRoomBorder)
