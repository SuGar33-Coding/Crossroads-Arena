extends Particles2D

var timeElapsed = 0.0

func _process(delta):
	timeElapsed += delta
	if timeElapsed > lifetime:
		queue_free()
