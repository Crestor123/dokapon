extends Camera3D

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			position.x -= event.relative.x / 100
			position.z -= event.relative.y / 100
	pass
