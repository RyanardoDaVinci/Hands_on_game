extends CanvasLayer

var toggle_screen : bool = false
var new_pause_state : bool = false

var last_hovered : int = 1


func _ready():
	$UI.visible = false


func _process(_delta):
	if GlobalVariables.in_swap:
		return
	show_last_hovered()

	if Input.is_action_just_pressed("pause"):
		new_pause_state = not get_tree().paused

		get_tree().paused = new_pause_state
		$UI.visible = new_pause_state

		if new_pause_state:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _on_continue_mouse_entered():
	last_hovered = 1

func _on_restart_mouse_entered():
	last_hovered = 2

func _on_quit_mouse_entered():
	last_hovered = 3



func _on_continue_pressed():
	new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	$UI.visible = new_pause_state
	if new_pause_state:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_restart_pressed():
	GlobalVariables.reset()
	new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().quit()


func show_last_hovered():
	if last_hovered == 1:
		$UI/Buttons/Continue/Border.visible = true
		$UI/Buttons/Restart/Border.visible = false
		$UI/Buttons/Quit/Border.visible = false
	elif last_hovered == 2:
		$UI/Buttons/Continue/Border.visible = false
		$UI/Buttons/Restart/Border.visible = true
		$UI/Buttons/Quit/Border.visible = false
	elif last_hovered == 3:
		$UI/Buttons/Continue/Border.visible = false
		$UI/Buttons/Restart/Border.visible = false
		$UI/Buttons/Quit/Border.visible = true
