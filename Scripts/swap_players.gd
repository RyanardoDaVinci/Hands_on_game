extends CanvasLayer

var toggle_screen = false
var new_pause_state = false
var in_options = false
var just_swapped = false


func _ready():
	$UI.visible = false


func _process(_delta):
	if Input.is_action_just_pressed("switch_character") and !in_options and not just_swapped:
		just_swapped = true
		new_pause_state = not get_tree().paused

		get_tree().paused = new_pause_state
		$UI.visible = new_pause_state

		if new_pause_state:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_swap_pressed():
	just_swapped = false
	new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	$UI.visible = new_pause_state
	if new_pause_state:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
