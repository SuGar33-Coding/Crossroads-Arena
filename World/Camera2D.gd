extends Camera2D


onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

func _ready():
	self.limit_top = topLeft.position.y
	self.limit_left = topLeft.position.x
	self.limit_bottom = bottomRight.position.y
	self.limit_right = bottomRight.position.x
