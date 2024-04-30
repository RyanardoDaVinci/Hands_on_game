extends CharacterBody3D

# Variables that should be ready when starting scene
@onready var camera = $Head/Camera3D as Camera3D
@onready var wall_ray = $Head/Wall_detection_ray
@onready var player_ray = $Head/Player_detection_ray

# Export variables that player can edit in node inspector
@export var speed = 1
@export var distance = 1
@export var max_throw = 6
@export var max_turns = 1
@export var fixed_amount_moves = false

# Mouse related variables
var mouseSensitivity = 350
var mouse_relative_x = 0
var mouse_relative_y = 0

var detected_player = false

# Check if player is moving
var moving = false

# Amount of moves player can do after throwing dice
var dice_throw_number

# Current active player
var active_player = null

var turns_taken = 0

# Input list (for movement)
var inputs = {
	"right": Vector3.RIGHT,
	"left": Vector3.LEFT,
	"forward": Vector3.FORWARD,
	"backward": Vector3.BACK
}


# Runs when scene starts
func _ready():
	GlobalVariables.position_theseus = $".".global_transform.origin
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	roll_dice()



# Constantly updates
func _process(_delta):
	GlobalVariables.position_theseus = $".".global_transform.origin
	active_player = GlobalVariables.active_character

	# Update label that shows how many moves are left
	$UI/MarginContainer/Moves_left.text = "Theseus moves: " + str(dice_throw_number)

	if not GlobalVariables.theseus_moving and not GlobalVariables.minotaur_moving:
		detect_other_player()
	elif GlobalVariables.minotaur_moving:
		detected_player = false

	if (active_player == 0):
		$UI.visible = true
	else:
		$UI.visible = false



# Check for player inputs
func _input(event):
	# If player is moving or not active, don't get any inputs
	if moving or active_player == 1:
		return

	# Update mouse movement (mouse)
	if event is InputEventMouseMotion:
		mouse_movement(event)

	# Check if player is rolling a dice ('r')
	if event.is_action_pressed("reroll"):
		if turns_taken < max_turns - 1:
			turns_taken += 1
			roll_dice()

	if event.is_action_pressed("switch_character"):
		detected_player = false
		turns_taken = 0
		roll_dice()

	# If player has moves left, move in input direction ('w, a, s, d')
	if dice_throw_number > 0:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				move(dir)



# Update mouse movement
func mouse_movement(event):
	rotation.y -= event.relative.x / mouseSensitivity
	camera.rotation.x -= event.relative.y / mouseSensitivity
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	mouse_relative_x = clamp(event.relative.x, -50, 50)
	mouse_relative_y = clamp(event.relative.y, -50, 10)



# Move player
func move(dir):
	# Direction player will move in based on camera direction
	var direction = inputs[dir].rotated(Vector3.UP, rotation.y)

	# Make sure player can only move on x-axis and y-axis, and not diagonal
	if abs(direction.x) > abs(direction.z):
		direction.z = 0
	else:
		direction.x = 0

	# Normalize so that when player looks in a diagonal, distance that is moved is the same
	direction = direction.normalized()

	# Wall detection based on what way player wants to move in (direction)
	wall_ray.target_position = direction.rotated(Vector3.UP, -rotation.y) * distance * 1.5
	wall_ray.force_raycast_update()

	# If ray isn't colliding, move in that direction
	if !wall_ray.is_colliding():
		# Update amount of moves left
		dice_throw_number -= 1

		# Move player
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position + direction * distance, 1.0/speed).set_trans(Tween.TRANS_SINE)
		moving = true
		GlobalVariables.theseus_moving = true
		await tween.finished
		moving = false
		GlobalVariables.theseus_moving = false



# Get random number between 1 and max_throw (6)
func roll_dice():
	if fixed_amount_moves:
		dice_throw_number = max_throw
	else:
		dice_throw_number = randi() % max_throw + 1



func detect_other_player():
	var target_position = GlobalVariables.position_minotaur
	var character_position = global_transform.origin
	var direction = (target_position - character_position).normalized()
	var angle = atan2(direction.x, direction.z)
	var character_rotation = global_transform.basis.get_euler().y
	angle -= character_rotation
	var rotation_in_degrees = rad_to_deg(angle) - 180
	player_ray.rotation_degrees.y = rotation_in_degrees

	if player_ray.is_colliding():
		var collider = player_ray.get_collider()

		if collider.get_name() == "Minotaur":
			camera.cull_mask = (1 << 0) | (1 << 2)
			if not detected_player:
				if active_player == 1:
					#print("Found Minotaur!")
					GlobalVariables.minotaur_located_positions.append(GlobalVariables.position_minotaur)
					#print(GlobalVariables.minotaur_located_positions)
				detected_player = true
		else:
			camera.cull_mask = (1 << 0) | (1 << 2)
			detected_player = false



func path_minotaur():
	pass
