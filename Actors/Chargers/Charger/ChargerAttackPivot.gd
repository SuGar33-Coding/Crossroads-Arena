class_name ChargerAttackPivot extends AttackPivot

onready var weaponCollision := $WeaponHitbox/WeaponCollision

func startCharge(chargeDirection: Vector2):
	weaponSprite.global_rotation = chargeDirection.angle() + deg2rad(45)
	weaponSprite.offset = Vector2(weaponStats.length, 0)
	
	# TODO: replace this with some other method of hit detection while charging
	weaponCollision.disabled = false
