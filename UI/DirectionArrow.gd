class_name DirectionArrow extends Node2D

const RANGE : int = 600

var target : NPC = null setget setTarget

onready var arrow : Sprite = $Sprite
onready var animPlayer : AnimationPlayer = $AnimationPlayer

func _ready():
	self.visible = false

func _physics_process(_delta):
	if is_instance_valid(target):
		var dist := self.global_position.distance_to(target.global_position)
		if dist < RANGE:
			self.visible = false
			animPlayer.stop(true)
		else:
			animPlayer.play("Breath")
			self.look_at(target.global_position)
			self.visible = true
		

func setTarget(newTarget : NPC):
	target = newTarget
	target.connect("no_health", self, "queue_free")
