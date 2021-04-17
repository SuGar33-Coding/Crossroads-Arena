class_name ChargerAttackPivot extends AttackPivot

func startCharge(chargeDirection: Vector2):
	weaponSprite.rotation_degrees = 45
	weaponSprite.offset = Vector2(weaponStats.length, 0)
	
	# TODO: replace this with some other method of hit detection while charging
	weaponCollision.disabled = false

func stopCharge():
	weaponSprite.rotation = restingRotation
	weaponSprite.offset = Vector2.ZERO
	
	weaponCollision.disabled = true
