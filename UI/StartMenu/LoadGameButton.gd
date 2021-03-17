extends Button


func _on_loadGame_pressed():
	var packedScene = load("res://SaveGames/savegame.tscn")
	
	var myScene = packedScene.instance()
	var curScene = get_tree().get_current_scene()
	get_tree().add_child(myScene)
	curScene.queue_free()
