extends Node3D

# Runs when scene starts
func _ready():
	pass



# Constantly updates
func _process(_delta):
	pass



# Check for inputs that are not in the project input map
func _unhandled_input(event):
	# Close game window when 'esc' is pressed
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
