extends StaticBody3D

@onready var button = $SubViewport/Button

var data = null

signal buttonPressed(data)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			buttonPressed.emit(data)

func set_data(new_data):
	data = new_data
