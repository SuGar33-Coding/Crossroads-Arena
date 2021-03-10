extends Area2D

export var damage = 1
export var knockbackValue = 475

func getSource() -> Vector2:
	return self.get_parent().global_position

func getKnockbackDirection(position) -> Vector2:
	return self.getSource().direction_to(position)
	
func getKnockbackVector(position) -> Vector2:
	return self.getKnockbackDirection(position) * knockbackValue
