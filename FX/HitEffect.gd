extends AnimatedSprite

class_name HitEffect

var sourcePos : Vector2

func init(sourcePosition : Vector2):
	sourcePos = sourcePosition

func _ready():
	self.look_at(sourcePos)
	
	self.position += self.global_position.direction_to(sourcePos) * 5
	self.play("HitEffect")
	self.connect("animation_finished", self, "_anim_finished")
	
func _anim_finished():
	queue_free()
