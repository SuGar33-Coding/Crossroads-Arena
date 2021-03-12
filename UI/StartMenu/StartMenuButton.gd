extends Button

# Path to the scene this button links to
export var pathToScene = ""

func _on_Button_mouse_entered():
	# Focuses on this button (changes the look)
	grab_focus()
	

func _on_Button_pressed():
	if(pathToScene != ""):
		get_tree().change_scene(pathToScene)
	else:
		# If there is nowhere to go, this button exits the game
		get_tree().quit()
