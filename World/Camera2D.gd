extends Camera2D


onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight
onready var tween = $Tween

var tweenDuration = .5

enum {
	UP,
	LEFT,
	DOWN,
	RIGHT
}

func _ready():
	setLimitsToPositions()
	
func transitionToRoom(topLeftVal, bottomRightVal, direction):
	var viewPortSize = get_viewport().get_visible_rect().size * self.zoom
	var halfViewPortSize = viewPortSize/2
	
	topLeft.position = topLeftVal
	bottomRight.position = bottomRightVal
	
	match direction:
		UP:
			self.limit_bottom = self.limit_top + viewPortSize.y
			tween.interpolate_property(self, "limit_top", self.limit_top, self.limit_top - viewPortSize.y, tweenDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.interpolate_property(self, "limit_bottom", self.limit_bottom, self.limit_bottom - viewPortSize.y, tweenDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		DOWN:
			self.limit_top = self.limit_bottom - viewPortSize.y
			tween.interpolate_property(self, "limit_top", self.limit_top, self.limit_top + viewPortSize.y, tweenDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.interpolate_property(self, "limit_bottom", self.limit_bottom, self.limit_bottom + viewPortSize.y, tweenDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		LEFT:
			self.limit_right = self.limit_left + viewPortSize.x
			tween.interpolate_property(self, "limit_left", self.limit_left, self.limit_left - viewPortSize.x, tweenDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.interpolate_property(self, "limit_right", self.limit_right, self.limit_right - viewPortSize.x, tweenDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		RIGHT:
			self.limit_left = self.limit_right - viewPortSize.x
			tween.interpolate_property(self, "limit_left", self.limit_left, self.limit_left + viewPortSize.x, tweenDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.interpolate_property(self, "limit_right", self.limit_right, self.limit_right + viewPortSize.x, tweenDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	tween.start()

func setLimitsToPositions():
	self.limit_top = topLeft.position.y
	self.limit_left = topLeft.position.x
	self.limit_bottom = bottomRight.position.y
	self.limit_right = bottomRight.position.x

func _on_Tween_tween_all_completed():
	setLimitsToPositions()
