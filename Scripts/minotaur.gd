extends CharacterBody3D

# Variables that should be ready when starting scene
@onready var camera = $Head/Camera3D as Camera3D
@onready var minimap_camera = $UI/MarginContainer/Minimap/SubViewportContainer/SubViewport/Minimap_camera as Camera3D
@onready var wall_ray = $Head/Wall_detection_ray
@onready var player_ray = $Head/Player_detection_ray
@onready var attack_area = $Attack_area
@onready var arrow = $Head/Arrow
@onready var ability_indicator = $UI/MarginContainer/Ability_indicator
#@onready var locked_in_label = $UI/MarginContainer/Locked_in

# Export variables that player can edit in node inspector
@export var speed = 1
@export var distance = 1
@export var max_throw = 5 # max is 10, otherwise, add more sprites for move icons
@export var max_turns = 1
@export var steps_lost_on_hit = 3
#@export var minimap_nerf_range = 8
@export var fixed_amount_moves = false
# how many turns before getting direction help
@export var turns_not_seen_theseus = 4

# Mouse related variables
var mouseSensitivity = 350
var mouse_relative_x = 0
var mouse_relative_y = 0

var detected_player = false

# Check if player is moving
var moving = false

## Variables to lock direction after first move (resets when player retrows)
#var direction_locked = false
#var lock_direction

# Amount of moves player can do after throwing dice
var dice_throw_number

# Did the Minotaur hit Theseus last turn?
var hit_theseus = false

# Current active player
var active_player = null

var move_one_dir = false

var turns_taken = 0

var not_seen_counter
var seen_him = false
var can_use_help = false
var used_help = false

var moveSprites: Array = []

# Input list (for movement)
var inputs = {
	"right": Vector3.RIGHT,
	"left": Vector3.LEFT,
	"forward": Vector3.FORWARD,
	"backward": Vector3.BACK
}



# Runs when scene starts
func _ready():
	GlobalVariables.position_minotaur = $".".global_transform.origin
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#locked_in_label.visible = false
	not_seen_counter = 0
	arrow.visible = false
	ability_indicator.visible = false
	roll_dice()

	var moveContainer = $UI/MarginContainer/Moves

	# Get all move sprites
	for i in range(max_throw):
		moveSprites.append(moveContainer.get_child(i))

	# Only display move sprites equal to max_throw + dash_boost (max amount of sprites now is 10)
	for i in range(max_throw):
		moveSprites[i].visible = true




# Constantly updates
func _process(_delta):
	GlobalVariables.position_minotaur = $".".global_transform.origin
	active_player = GlobalVariables.active_character

	attack_area.rotation.y = -rotation.y

	handle_icons()
	show_ability_indicator()

	#see_theseus_on_minimap()

	# Update label that shows how many moves are left
	#$UI/MarginContainer/Moves_left.text = "Minotaur moves: " + str(dice_throw_number) + "\nDirection ability: " + str(can_use_help)

	if not GlobalVariables.theseus_moving and not GlobalVariables.minotaur_moving:
		detect_other_player()
	elif GlobalVariables.theseus_moving:
		detected_player = false

	if (active_player == 1):
		$UI.visible = true
	else:
		$UI.visible = false

	if not_seen_counter < 1:
		can_use_help = true

	if seen_him:
		can_use_help = false



# Check for player inputs
func _input(event):
	# If player is moving or not active, don't get any inputs
	if moving or active_player == 0:
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
		if used_help:
			can_use_help = false
			arrow.visible = false
		detected_player = false
		turns_taken = 0
		seen_him = false

	if event.is_action_pressed("help_action"):
		try_help()

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



#func see_theseus_on_minimap():
	#if GlobalVariables.shortest_goal_distance <= minimap_nerf_range:
		#minimap_camera.cull_mask = (1 << 0) | (1 << 1) | (1 << 3)
	#else:
		#minimap_camera.cull_mask = (1 << 0) | (1 << 3)


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
		# Lock direction and check if input direction is the same
		#if move_one_dir:
			#if !direction_locked:
				#lock_direction = direction
				#direction_locked = true
			#elif direction != lock_direction:
				#return
#
			## Direction wasn't locked so lock it
			#direction = lock_direction

		# Update amount of moves left
		dice_throw_number -= 1

		# Move player
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position + direction * distance, 1.0/speed).set_trans(Tween.TRANS_SINE)
		moving = true
		GlobalVariables.minotaur_moving = true
		await tween.finished
		moving = false
		GlobalVariables.minotaur_moving = false



func handle_icons():
	# Handle move display
	for i in range(max_throw):
		moveSprites[i].visible = i < dice_throw_number


func show_ability_indicator():
	if can_use_help:
		ability_indicator.visible = true
	else:
		ability_indicator.visible = false



func not_seen_helper():
	if seen_him:
		not_seen_counter = turns_not_seen_theseus
	elif not can_use_help and not_seen_counter > 0:
		not_seen_counter -= 1


func try_help():
	if not can_use_help:
		return
	used_help = true
	arrow.visible = true
	seen_him = false
	not_seen_counter = turns_not_seen_theseus
	print("help!!!")


# Get random number between 1 and max_throw (4)
func roll_dice():
	#direction_locked = false
	move_one_dir = false
	if fixed_amount_moves:
		dice_throw_number = max_throw
		if hit_theseus:
			hit_theseus = false
			dice_throw_number = dice_throw_number - steps_lost_on_hit
	else:
		dice_throw_number = randi() % max_throw + 1

	not_seen_helper()


func detect_other_player():
	var target_position = GlobalVariables.position_theseus
	var character_position = global_transform.origin
	var direction = (target_position - character_position).normalized()
	var angle = atan2(direction.x, direction.z)
	var character_rotation = global_transform.basis.get_euler().y
	angle -= character_rotation
	var rotation_in_degrees = rad_to_deg(angle) - 180
	player_ray.rotation_degrees.y = rotation_in_degrees
	arrow.rotation_degrees.y = rotation_in_degrees + 90

	if player_ray.is_colliding():
		var collider = player_ray.get_collider()

		if collider.get_name() == "Theseus":
			camera.cull_mask = (1 << 0) | (1 << 2) | (1 << 4)
			#locked_in_label.visible = true
			if not detected_player:
				if active_player == 0:
					#print("Found Theseus!")
					GlobalVariables.theseus_located_positions.append(GlobalVariables.position_theseus)
					#print(GlobalVariables.theseus_located_positions)
				detected_player = true
				seen_him = true
				move_one_dir = true
		else:
			if detected_player:
				detected_player = false
			move_one_dir = false
			#$Locked_in_timer.start()

func if_theseus_hit(body):
	if body.get_name() == "Theseus":
		body.lives_left = body.lives_left - 1
		# if Minotaurus is moving, stop his movement
		if active_player == 1:
			dice_throw_number = 0
		hit_theseus = true
		if body.lives_left <= 0:
			await get_tree().create_timer(1).timeout
			body.lives_left = body.max_lives
			GlobalVariables.reset()
			get_tree().reload_current_scene()

func _on_area_3d_body_entered(body):
	if_theseus_hit(body)

# duplicate code
func _on_area_3d_2_body_entered(body):
	if_theseus_hit(body)


#func _on_locked_in_timer_timeout():
	#locked_in_label.visible = false
	#camera.cull_mask = (1 << 0)
