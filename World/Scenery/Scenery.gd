class_name Scenery extends WorldSpawn

onready var animationPlayer := $AnimationPlayer
onready var collider := $CollisionShape2D
onready var shakeFx: Particles2D = $Particles2D 

func _ready():
	self.connect("body_entered", self, "_play_shake")

func _play_shake(_body):
	if animationPlayer != null:
		animationPlayer.play("Shake")
	if shakeFx != null:
		shakeFx.emitting = true
