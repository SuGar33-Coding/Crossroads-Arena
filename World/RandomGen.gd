extends Node2D

# Preload in all rooms
const BaseRoom = preload("res://World/Rooms/BaseRoom.tscn")
const PlusRoom = preload("res://World/Rooms/PlusRoom.tscn")
const TreasureRoom = preload("res://World/Rooms/TreasureRoom.tscn")
const StartRoom = preload("res://World/Rooms/HomeRoom.tscn")

export(bool) var scrollCamera = true

# Create room arrays
# roomTypes stores enums/ints of the type of each room
var roomTypes = []
# rooms will store the actual room objects
var rooms = []
onready var camera = $Camera2D
onready var player = $Player
onready var mapGridContainer = $MapOverlay/GridContainer
onready var mapOverlay = $MapOverlay

# Change to having the matrix store a variety of integers / enums
# This will store the type of every room that will give information about that location
# Then we can lazily generate nearby rooms

var worldWidth = 17
var worldHeight = 17
var halfColumnWidth = 2
var roomWidtth = 1088
var roomHeight = 704
var currentRoom : Room
var startingRow : int = worldHeight/2
var startingCol : int = worldWidth/2

func _init():
	randomize()
	var x = startingRow
	var y = startingCol
	
	for row in range(worldHeight):
		roomTypes.append([])
		for col in range(worldWidth):
			roomTypes[row].append(0)
			
	for row in range(startingRow-halfColumnWidth, startingRow+halfColumnWidth+1):
		for col in range(len(roomTypes[row])):
			roomTypes[row][col] = self.generateRandomRoomType() 
			
	for col in range(startingCol-halfColumnWidth, startingCol+halfColumnWidth+1):
		for row in range(len(roomTypes)):
			roomTypes[row][col] = self.generateRandomRoomType() 
	
	"""for i in range(len(roomTypes)*len(roomTypes[0])):
		roomTypes[x][y] = randi() % 2 + 1
		var dir = (randi() % 4)*90
		x += self.lengthdir_x(1, dir)
		y += self.lengthdir_y(1, dir)
		x = clamp(x, 0, len(roomTypes)-1)
		y = clamp(y, 0, len(roomTypes[x])-1)"""
		
func _ready():
	print(roomTypes)
	for row in range(len(roomTypes)):
		rooms.append([])
		for col in range(len(roomTypes[row])):
			rooms[row].append(null)
			#uncomment this for instancing all rooms at once
			#instanceRoom(row, col)
			
	roomTypes[startingRow][startingCol] = 4
	instanceRoom(startingRow, startingCol)
	currentRoom = rooms[startingRow][startingCol]
	mapOverlay.generateMapOverlay(roomTypes)

#Debug var
var zoomLimit = .5
func _physics_process(delta):
	
	if Input.is_action_just_released("wheeldown"):
		camera.zoom.x += .25
		camera.zoom.y += .25
		camera.topLeft.position = Vector2(-1000000000, -1000000000)
		camera.bottomRight.position = Vector2(100000000, 100000000)
		camera.setLimitsToPositions()
		
	if Input.is_action_just_released("wheelup") and $Camera2D.zoom.x > zoomLimit and $Camera2D.zoom.y > zoomLimit:
		camera.zoom.x -= .25
		camera.zoom.y -= .25
		
	if Input.is_action_just_released("openmap"):
		mapGridContainer.visible = not mapGridContainer.visible
		
	if Input.is_action_just_pressed("addlevel"):
		PlayerStats.playerLevel += 1
	
	if camera.zoom.x <= zoomLimit and camera.zoom.y <= zoomLimit:
		self.setCameraLimitsForRoom(currentRoom)

# Randomly selects and returns a random enum/int that determines room type
# Sets percentages for each room type
func generateRandomRoomType() -> int:
	var r = randi() % 100
	
	if r < 45:
		return 1
	elif r < 90:
		return 2
	else:
		return 3

# Handles the boundaries of the room in position row, col
func handleBoundaries(row : int, col : int):
	if row < 0 or row >= len(roomTypes) or col < 0 or col >= len(roomTypes[row]):
		return
		
	var roomType = roomTypes[row][col]
	if roomType != 0:
		var room = rooms[row][col]
		var boundaryTop : Boundary = room.get_node("BoundaryTop")
		var boundaryBottom : Boundary = room.get_node("BoundaryBottom")
		var boundaryRight : Boundary = room.get_node("BoundaryRight")
		var boundaryLeft : Boundary = room.get_node("BoundaryLeft")
		if row == 0 or roomTypes[row-1][col] == 0:
			boundaryTop.isClosed()
		else:
			boundaryTop.isOpen()
			
		if row == worldHeight-1 or roomTypes[row+1][col] == 0:
			boundaryBottom.isClosed()
		else:
			boundaryBottom.isOpen()
			
		if col == 0 or roomTypes[row][col-1] == 0:
			boundaryLeft.isClosed()
		else:
			boundaryLeft.isOpen()
			
		if col == worldWidth-1 or roomTypes[row][col+1] == 0:
			boundaryRight.isClosed()
		else:
			boundaryRight.isOpen()
		mapOverlay.roomDiscovered(row, col)
		
func instanceRoom(row : int, col : int):
	if row < 0 or row > len(roomTypes) or col < 0 or col > len(roomTypes[row]):
		return
	elif roomTypes[row][col] != 0 and rooms[row][col] == null:
		var room : Room
		match roomTypes[row][col]:
			1:
				room = BaseRoom.instance()
			2:
				room = PlusRoom.instance()
			3:
				room = TreasureRoom.instance()
			4:
				room = StartRoom.instance()
		room.row = row
		room.col = col
		# Multiply by room size, shift back so centered, shift back again so that the central room is centered
		var room_pos = Vector2(roomWidtth*col, roomHeight*row) + Vector2(-roomWidtth/2, -roomHeight/2) + Vector2(-roomWidtth*startingCol, -roomHeight*startingRow)
		room.global_position = room_pos
		self.call_deferred("add_child", room)
		self.call_deferred("move_child", room ,0)
		rooms[row][col] = room
		self.call_deferred("handleBoundaries", row, col)
		room.call_deferred("pauseRoom")
	
func lengthdir_x(length, direction):
	return length*cos(direction)
	
func lengthdir_y(length, direction):
	return length*sin(direction)
	
func setCameraLimitsForRoom(room : Room):
	var roomCenter = room.global_position + Vector2(roomWidtth/2, roomHeight/2)
	var directionVector : Vector2  = camera.global_position.direction_to(roomCenter)
	var direction
	
	if abs(directionVector.x) > abs(directionVector.y):
		if directionVector.x < 0:
			direction = camera.LEFT
		else:
			direction = camera.RIGHT
	else:
		if directionVector.y < 0:
			direction = camera.UP
		else:
			direction = camera.DOWN
	
	camera.transitionToRoom(room.global_position, room.global_position + Vector2(roomWidtth, roomHeight), direction)
	
# Body should be player body and room is the room they entered
func _player_entered_room(body, room : Room):
	if not body.is_in_group("RangedWeapons"):
		currentRoom = room
		var row = room.row
		var col = room.col
		mapOverlay.setCurrentRoom(row, col)
		
		if scrollCamera:
			self.setCameraLimitsForRoom(room)
		
		# Now that we've found the room, make sure all adjacent rooms are instantiated
		if row != 0:
			instanceRoom(row-1, col)
		if col != 0:
			instanceRoom(row, col-1)
		if row != len(rooms)-1:
			instanceRoom(row+1, col)
		if col != len(rooms[row])-1:
			instanceRoom(row, col+1)
