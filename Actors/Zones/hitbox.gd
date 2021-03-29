extends Area2D

class_name Hitbox

export var damage : int = 1
export var knockbackValue : float = 475.0

func getSourcePos() -> Vector2:
	return self.get_parent().global_position

func getKnockbackDirection(position) -> Vector2:
	return self.getSourcePos().direction_to(position)
	
func getKnockbackVector(position) -> Vector2:
	return self.getKnockbackDirection(position) * knockbackValue
