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
	GlobalVariables.shortest_goal_distance = calculate_goal_distance()



func _input(event):
	if event.is_action_pressed("switch_character"):
		# Switch active character
		# if active character == theseus
		if GlobalVariables.active_character == 0 and !GlobalVariables.theseus_moving:
			GlobalVariables.active_character = 1
			GlobalVariables.minotaur_located_positions.clear()
			minotaur.camera.current = true
			# if active character == minotaur
		elif !GlobalVariables.minotaur_moving:
			GlobalVariables.active_character = 0
			GlobalVariables.theseus_located_positions.clear()
			theseus.camera.current = true



# Check for inputs that are not in the project input map
func _unhandled_input(event):
	# Close game window when 'esc' is pressed
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func calculate_goal_distance():
	var player_position = GlobalVariables.position_theseus
	player_position.y = 0
	var shortest_goal_distance = -1
	for goal in $Goals.get_children():
		var goal_position = goal.global_transform.origin
		goal_position.y = 0
		var goal_distance = player_position.distance_to(goal_position)
		if shortest_goal_distance == -1 or shortest_goal_distance > goal_distance:
			shortest_goal_distance = goal_distance
	return shortest_goal_distance
