extends StaticBody3D

@onready var button = $SubViewport/Button

var traverseLocation = null

signal buttonPressed(location)

func _ready():
	button.connect("input_event", _on_input_event)
	
func _on_button_pressed():
	print(traverseLocation.locationName)
	buttonPressed.emit(traverseLocation)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			button.emit_signal("pressed")
