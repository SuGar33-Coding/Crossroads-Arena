extends Node2D

const BaseRoom = preload("res://World/BaseRoom.tscn")
const PlusRoom = preload("res://World/PlusRoom.tscn")

var roomTypes = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
var rooms = []
onready var camera = $Camera2D

# Change to having the matrix store a variety of integers / enums
# This will store the type of every room that will give information about that location
# Then we can lazily generate nearby rooms
var startingRow = len(roomTypes)/2
var startingCol = len(roomTypes[startingRow])/2
var roomWidtth = 1088
var roomHeight = 704

func _init():
	randomize()
	var x = startingRow
	var y = startingCol
	#for i in range(len(roomTypes)*len(roomTypes[0])):
	for i in range(len(roomTypes)*len(roomTypes[0])):
		roomTypes[x][y] = randi() % 2 + 1
		var dir = (randi() % 4)*90
		x += self.lengthdir_x(1, dir)
		y += self.lengthdir_y(1, dir)
		x = clamp(x, 0, len(roomTypes)-1)
		y = clamp(y, 0, len(roomTypes[x])-1)
		
func _ready():
	print(roomTypes)
	for row in range(len(roomTypes)):
		rooms.append([])
		for col in range(len(roomTypes[row])):
			rooms[row].append(null)
			
	instanceRoom(startingRow, startingCol)

# Handles the boundaries of the room in position row, col
func handleBoundaries(row, col):
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
			
		if row == 3 or roomTypes[row+1][col] == 0:
			boundaryBottom.isClosed()
		else:
			boundaryBottom.isOpen()
			
		if col == 0 or roomTypes[row][col-1] == 0:
			boundaryLeft.isClosed()
		else:
			boundaryLeft.isOpen()
			
		if col == 3 or roomTypes[row][col+1] == 0:
			boundaryRight.isClosed()
		else:
			boundaryRight.isOpen()

func _physics_process(delta):
	if Input.is_action_just_released("wheeldown"):
		camera.zoom.x += .25
		camera.zoom.y += .25
		
	if Input.is_action_just_released("wheelup") and $Camera2D.zoom.x > 1 and $Camera2D.zoom.y > 1:
		camera.zoom.x -= .25
		camera.zoom.y -= .25
		
func instanceRoom(row : int, col : int):
	if roomTypes[row][col] != 0 and rooms[row][col] == null:
		var room : Room
		match roomTypes[row][col]:
			1:
				room = BaseRoom.instance()
			2:
				room = PlusRoom.instance()
		var room_pos = Vector2(roomWidtth*col, roomHeight*row) + Vector2(-roomWidtth/2, -roomHeight/2) + Vector2(-roomWidtth*startingCol, -roomHeight*startingRow)
		room.global_position = room_pos
		self.call_deferred("add_child", room)
		rooms[row][col] = room
		self.call_deferred("handleBoundaries", row, col)
		room.call_deferred("pauseRoom")
	
func lengthdir_x(length, direction):
	return length*cos(direction)
	
func lengthdir_y(length, direction):
	return length*sin(direction)
	
# Body should be player body and room is the room they entered
func _player_entered_room(body, room : Room):
	for row in range(len(rooms)):
		for col in range(len(rooms[row])):
			if room == rooms[row][col]:
				# Now that we've found the room, make sure all adjacent rooms are instantiated
				if row != 0:
					instanceRoom(row-1, col)
				if col != 0:
					instanceRoom(row, col-1)
				if row != len(rooms)-1:
					instanceRoom(row+1, col)
				if col != len(rooms[row])-1:
					instanceRoom(row, col+1)
