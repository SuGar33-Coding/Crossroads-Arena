class_name ChargerAttackPivot extends AttackPivot

onready var weaponCollisionHeight := (weaponCollision.shape as CapsuleShape2D).height
onready var weaponCollisionPos := weaponCollision.position

func startCharge(chargeDirection: Vector2):
	weaponSprite.rotation_degrees = 45
	weaponSprite.position = Vector2(weaponStats.length/3, 0)
	(weaponCollision.shape as CapsuleShape2D).height = weaponStats.length/3
	weaponCollision.position -= Vector2(weaponCollisionHeight - weaponStats.length/3, 0)

func stopCharge():
	weaponSprite.rotation = returnRot
	weaponSprite.position = restingPos.position
	(weaponCollision.shape as CapsuleShape2D).height = weaponCollisionHeight
	weaponCollision.position = weaponCollisionPos
	
	weaponCollision.disabled = true
