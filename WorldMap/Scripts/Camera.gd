extends Camera3D

var followTarget : Node = null

func _process(delta):
	if followTarget:
		focus(followTarget)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			position.x -= event.relative.x / 100
			position.z -= event.relative.y / 100
	pass

func focus(target : Node):
	position.x = target.position.x
	position.z = target.position.z

func set_followTarget(target : Node):
	followTarget = target

func unset_followTarget():
	followTarget = null
