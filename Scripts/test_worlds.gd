extends Node3D

var active_character = null

# Runs when scene starts
func _ready():
	# set the initial active character to 0 (Theseus)
	active_character = 0
	$Theseus.camera.current = true



# Constantly updates
func _process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("switch_character"):
		# Switch active character
		if active_character == 0:
			active_character = 1
			$Minotaur.camera.current = true
		else:
			active_character = 0
			$Theseus.camera.current = true

# Check for inputs that are not in the project input map
func _unhandled_input(event):
	# Close game window when 'esc' is pressed
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
