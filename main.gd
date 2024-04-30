extends Node3D

var active_character = null

@onready var theseus = $Players/Theseus
@onready var minotaur = $Players/Minotaur
@onready var ghost_locations = $Ghosts

var ghosts = load("res://Scenes/ghosts.tscn")
var instance
var moved = false

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
		moved = false
		spawn_ghosts()
		# Switch active character
		if GlobalVariables.active_character == 0:
			GlobalVariables.active_character = 1
			GlobalVariables.minotaur_located_positions.clear()
			minotaur.camera.current = true
		else:
			GlobalVariables.active_character = 0
			GlobalVariables.theseus_located_positions.clear()
			theseus.camera.current = true

	if event.is_action_pressed("forward") or event.is_action_pressed("backward") or event.is_action_pressed("left") or event.is_action_pressed("right"):
		moved = true




# Check for inputs that are not in the project input map
func _unhandled_input(event):
	# Close game window when 'esc' is pressed
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()


func spawn_ghosts():
	var player
	var player_location

	if GlobalVariables.active_character == 0:
		player = GlobalVariables.theseus_located_positions
		player_location = GlobalVariables.position_theseus
	else:
		player = GlobalVariables.minotaur_located_positions
		player_location = GlobalVariables.position_minotaur

	while not moved:
		for i in range(player.size()):
			var spawn_point = player[i]
			if spawn_point != player_location:
				instance =  ghosts.instantiate()
				instance.position = spawn_point
				ghost_locations.add_child(instance)

				if ghost_locations.get_child_count() > 1:
					var ghost_to_delete = ghost_locations.get_child(0)
					ghost_to_delete.queue_free()

				await get_tree().create_timer(0.4).timeout

		await get_tree().create_timer(0.8).timeout

	for child in ghost_locations.get_children():
		child.queue_free()
