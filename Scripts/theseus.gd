extends CharacterBody3D

# Variables that should be ready when starting scene
@onready var camera = $Head/Camera3D as Camera3D
@onready var wall_ray = $Head/Wall_detection_ray
@onready var player_ray = $Head/Player_detection_ray
@onready var dash_indicator = $UI/MarginContainer/Dash_indicator
#@onready var fuck_you = $UI/MarginContainer/Fuck_you

# Export variables that player can edit in node inspector
@export var speed = 1
@export var distance = 1
@export var max_throw = 4 # max for max_throw + dash_boost = 10, otherwise, add more sprites for move icons
@export var dash_boost = 3
@export var max_turns = 1
@export var max_lives = 2 # max is 5, otherwise, add more sprites for health icons
#@export var move_back_range = 0
#@export var move_back_chance = 0
@export var fixed_amount_moves = false
# amount of turns before can dash again
@export var dash_cooldown_amount = 4

# Mouse related variables
var mouseSensitivity = 350
var mouse_relative_x = 0
var mouse_relative_y = 0

var detected_player = false

# Check if player is moving
var moving = false

# Amount of moves player can do after throwing dice
var dice_throw_number

# Number of lives left
var lives_left
var healthSprites : Array = []

var moveSprites: Array = []

# Current active player
var active_player = null

# Previous position of player during this turn
var previous_position = null

var turns_taken = 0

var can_dash = true

var dash_cooldown_counter

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
	lives_left = max_lives
	dash_cooldown_counter = 0
	dash_indicator.visible = false
	roll_dice()

	var healthContainer = $UI/MarginContainer/Health
	var moveContainer = $UI/MarginContainer/Moves

		# Get all health sprites
	for child in healthContainer.get_children():
		healthSprites.append(child)

	# Only display health sprites equal to max_lives (max amount of sprites now is 5)
	for i in range(max_lives):
		healthSprites[i].visible = true

	# Get all move sprites
	for i in range(max_throw + dash_boost):
		moveSprites.append(moveContainer.get_child(i))

	# Only display move sprites equal to max_throw + dash_boost (max amount of sprites now is 10)
	for i in range(max_throw + dash_boost):
		moveSprites[i].visible = true



# Constantly updates
func _process(_delta):
	GlobalVariables.position_theseus = $".".global_transform.origin
	active_player = GlobalVariables.active_character

	handle_icons()
	show_dash_indicator()

	## Update label that shows how many moves are left
	#$UI/MarginContainer/Stats.text = "Moves left: " + str(dice_throw_number)

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

	if event.is_action_pressed("help_action"):
		try_dash()

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

		# Update previous position
		previous_position = GlobalVariables.position_theseus

		# Move player
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position + direction * distance, 1.0/speed).set_trans(Tween.TRANS_SINE)
		moving = true
		GlobalVariables.theseus_moving = true
		await tween.finished
		moving = false
		GlobalVariables.theseus_moving = false

		## if theseus in range of goal, random chance to move back 1 spot
		#if GlobalVariables.shortest_goal_distance <= move_back_range:
			#if randf() < move_back_chance and previous_position != null:
				#fuck_you.visible = true
				#var tween2 = get_tree().create_tween()
				#tween2.tween_property(self, "position", previous_position, 1.0/speed).set_trans(Tween.TRANS_SINE)
				#moving = true
				#GlobalVariables.theseus_moving = true
				#await tween2.finished
				#moving = false
				#GlobalVariables.theseus_moving = false
				#previous_position = null
				#fuck_you.visible = false



func handle_icons():
	# Handle health display
	for i in range(max_lives):
		healthSprites[i].visible = i < lives_left

	# Handle move display
	for i in range(max_throw + dash_boost):
		moveSprites[i].visible = i < dice_throw_number



func show_dash_indicator():
	if can_dash:
		dash_indicator.visible = true
	else:
		dash_indicator.visible = false


func try_dash():
	if not can_dash:
		return
	elif dash_cooldown_counter == 0:
		can_dash = false
		dice_throw_number += dash_boost
		dash_cooldown_counter = dash_cooldown_amount

# Get random number between 1 and max_throw (6)
func roll_dice():
	if fixed_amount_moves:
		dice_throw_number = max_throw
	else:
		dice_throw_number = randi() % max_throw + 1

	if not can_dash and dash_cooldown_counter > 0:
		dash_cooldown_counter -= 1

	if dash_cooldown_counter == 0:
		can_dash = true



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
			if detected_player:
				detected_player = false
			$Locked_in_timer.start()

func _on_locked_in_timer_timeout():
	camera.cull_mask = (1 << 0)
