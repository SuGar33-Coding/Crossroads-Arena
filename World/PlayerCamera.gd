extends Camera2D

class_name MainCamera

onready var topLeft : Node2D = $Limits/TopLeft
onready var bottomRight : Node2D = $Limits/BottomRight
onready var tween = $Tween

# Camera shake stuff
export var decay = 1
export var max_offset = Vector2(100,75)
export var max_roll = .1

var noise = OpenSimplexNoise.new()

var trauma = 0.0
var trauma_power = 2
var noise_y = 0


var tweenDuration = .5

enum {
	UP,
	LEFT,
	DOWN,
	RIGHT
}

func _ready():
	setLimitsToPositions()
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	
func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	
func transitionToRoom(topLeftVal, bottomRightVal, direction):
	var viewPortSize = get_viewport().get_visible_rect().size * self.zoom
	
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
	self.limit_top = int(topLeft.position.y)
	self.limit_left = int(topLeft.position.x)
	self.limit_bottom = int(bottomRight.position.y)
	self.limit_right = int(bottomRight.position.x)

func _on_Tween_tween_all_completed():
	setLimitsToPositions()

func add_trauma(amount):
	# Minimum amount of hit trauma is .3
	trauma = max(.3, min(trauma + amount, 1.0))
	
func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)
	
