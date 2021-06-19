extends Position2D

class_name FloatingText

onready var label = $Label
onready var tween = $Tween

export var startingScale := Vector2(0, 0)
export var damageColor : String = "ff4800"
export var healColor : String = "2eff27"
export var verticalVelocity : float = 40.0
export var coneSize : int = 60

var amount = 0
# Whether it is damage or healing
var isDamage := true
var velocity := Vector2.ZERO

func _ready():
	label.set_text(str(amount))
	scale = startingScale
	if isDamage:
		label.set_deferred("modulate", Color(damageColor))
		label.set_text("-"+label.text)
	else:
		label.set_deferred("modulate", Color(healColor))
		label.set_text("+"+label.text)
		
	var sideSway = randi() % coneSize + 1 - coneSize/2
	velocity = Vector2(sideSway, verticalVelocity)
	
	tween.interpolate_property(self, 'scale', scale, Vector2(1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1,1), Vector2(0,0), .7, Tween.TRANS_LINEAR, Tween.EASE_OUT, .3)
	tween.start()

func _physics_process(delta):
	position -= velocity * delta

func _on_Tween_tween_all_completed():
	queue_free()
