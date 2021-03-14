extends Hitbox

func _on_Hitbox_area_entered(area):
	PlayerStats.currentXP += self.damage
