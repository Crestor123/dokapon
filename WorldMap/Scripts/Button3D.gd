extends StaticBody3D

@onready var button = $SubViewport/Button

func _ready():
	button.connect("input_event", _on_Button3D_input_event)
	

func _on_Button3D_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			button.emit_signal("pressed")
	pass

func _on_button_pressed():
	print("pressed")
