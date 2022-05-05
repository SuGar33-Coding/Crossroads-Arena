class_name ChargerAttackPivot extends AttackPivot

func startCharge(_chargeDirection: Vector2):
	weaponSprite.rotation_degrees = 45
	weaponSprite.position = Vector2(weaponStats.length/3, 0)

func stopCharge():
	weaponSprite.rotation = returnRot
	weaponSprite.position = restingPos.position
	
	weaponCollision.disabled = true
