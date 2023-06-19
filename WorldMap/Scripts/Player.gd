extends CharacterBody3D

@export var button : PackedScene

@onready var traverseButtons = $TraverseButtons

var currentLocation = null
var nextLocation = null

var t = 0.0

func _physics_process(delta):
	if nextLocation != null:
		t += delta
		transform = currentLocation.transform.interpolate_with(nextLocation.transform, t)
		if transform == nextLocation.transform:
			currentLocation = nextLocation
			nextLocation = null
			create_buttons()
	else:
		t = 0.0
	
	pass

func start_turn():
	create_buttons()

#Takes a MapPath node, and moves the player along it
func traverse(location : Node):
	delete_buttons()
	nextLocation = location
	pass

#Create a button for each path from the current node
func create_buttons():
	if !currentLocation:
		return
		
	for path in currentLocation.paths:
		var newButton = button.instantiate()
		traverseButtons.add_child(newButton)
		newButton.global_position = global_position
		newButton.global_position.y += 1.1
		
		newButton.global_position.x = (path.to.global_position.x + path.from.global_position.x) / 2
		newButton.global_position.z = (path.to.global_position.z + path.from.global_position.z) / 2
		
		newButton.buttonPressed.connect(traverse)
		
		if currentLocation == path.from:
			newButton.traverseLocation = path.to
			newButton.look_at(path.to.global_position, Vector3.UP)
		else:
			newButton.traverseLocation = path.from
			newButton.look_at(path.from.global_position, Vector3.UP)
		newButton.rotation.x = 0
		newButton.rotation.z = 0
	pass

func delete_buttons():
	for child in traverseButtons.get_children():
		child.queue_free()
	print(traverseButtons.get_child_count())
