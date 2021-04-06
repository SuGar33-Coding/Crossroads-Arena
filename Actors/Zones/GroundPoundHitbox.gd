extends Hitbox


func _ready():
	self.damage = get_node("../Stats").con * 5

