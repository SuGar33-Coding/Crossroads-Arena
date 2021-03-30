extends Area2D

class_name Hurtbox

var invincible = false setget setInvincible

onready var timer = $InvulnTimer
onready var collisionShape = $HurtboxCollision

func setInvincible(value):
	invincible = value
	if invincible == true:
		collisionShape.set_deferred("disabled", true)
	else:
		collisionShape.set_deferred("disabled", false)
	
func startInvincibility(duration):
	self.invincible = true
	timer.start(duration)
	
func _on_invuln_timeout():
	self.invincible = false
