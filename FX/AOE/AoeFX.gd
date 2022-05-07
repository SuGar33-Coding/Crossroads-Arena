extends Resource

class_name AoeFX

enum Type {
	PLACE,
	RANGED,
	MOVING,
	LOBBED
}

export (Type) var aoeType
# Pre-aoe affects time in seconds
export var chargeupTime := 1.0
export (Resource) var effectMaterial
export var particleLifetime := 1
export var numParticles := 100
export var speedScale := 1.0
# How much the effect's YSort position should be lowered
export var ysortOffset := 15
