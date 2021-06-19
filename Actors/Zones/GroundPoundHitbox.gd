extends Hitbox

export(float) var hitboxRadius := 17.5
export(float) var hitboxHeight := 20.0

onready var hitboxCollision := $hitboxCollision

func _ready():
	self.damage = pow(get_node("../../Stats").con, 2.5)
	
	var shape : CapsuleShape2D = CapsuleShape2D.new()
	shape.radius = hitboxRadius
	shape.height = hitboxHeight
	hitboxCollision.shape = shape
