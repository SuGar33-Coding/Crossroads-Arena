extends CanvasLayer

var emptyImage := preload("res://Assets/Wall.png")

var roomTypes := []
var roomTextures := []
var rectScale := Vector2(0,0)
var overlayOpacity := .4

onready var gridContainer := $GridContainer

func generateMapOverlay(roomTypeArray : Array):
	roomTypes = roomTypeArray
	gridContainer.columns = len(roomTypes[0])
	
	for row in range(len(roomTypes)):
		roomTextures.append([])
		for col in range(gridContainer.columns):
			var textureRect = TextureRect.new()
			if(roomTypes[row][col] != 0):
				textureRect.texture = emptyImage
			textureRect.size_flags_horizontal = textureRect.SIZE_EXPAND_FILL
			textureRect.size_flags_vertical = textureRect.SIZE_EXPAND_FILL
			
			textureRect.expand = true
			textureRect.rect_min_size = rectScale
			textureRect.modulate = Color(0,0,0, overlayOpacity)
			
			roomTextures[row].append(textureRect)
			
			gridContainer.call_deferred("add_child", textureRect)
	
	
func roomDiscovered(row : int, col : int):
	var roomTexture = roomTextures[row][col]
	
	match roomTypes[row][col]:
		1:
			roomTexture.modulate = Color(0,0,1,overlayOpacity)
		2:
			roomTexture.modulate = Color(1,0,0,overlayOpacity)
