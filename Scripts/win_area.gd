extends Area3D

func _on_body_entered(body):
	if body.get_name() == "Theseus":
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()
