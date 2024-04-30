extends Node3D

var active_character = null

@onready var theseus = $Players/Theseus
@onready var minotaur = $Players/Minotaur

# Runs when scene starts
func _ready():
	# set the initial active character to 0 (Theseus)
	GlobalVariables.active_character = 0
	theseus.camera.current = true



# Constantly updates
func _process(_delta):
	pass



func _input(event):
	if event.is_action_pressed("switch_character"):
		# Switch active character
		if GlobalVariables.active_character == 0:
			GlobalVariables.active_character = 1
			GlobalVariables.minotaur_located_positions.clear()
			minotaur.camera.current = true
		else:
			GlobalVariables.active_character = 0
			GlobalVariables.theseus_located_positions.clear()
			theseus.camera.current = true



# Check for inputs that are not in the project input map
func _unhandled_input(event):
	# Close game window when 'esc' is pressed
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
