extends StaticBody3D

@onready var button = $SubViewport/Button

var traverseLocation = null

signal buttonPressed(location)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			buttonPressed.emit(traverseLocation)
