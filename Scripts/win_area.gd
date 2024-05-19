extends Area3D

func _ready():
	$Win_screen.visible = false

func _on_body_entered(body):
	if body.get_name() == "Theseus":
		trigger_win()

func trigger_win():
	$Win_screen/Fade_animation.play("Fade_in")
	$Win_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	GlobalVariables.in_swap = true

func _on_restart_pressed():
	get_tree().paused = false
	GlobalVariables.reset()
	get_tree().reload_current_scene()
