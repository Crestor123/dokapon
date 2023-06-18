extends CharacterBody3D

@export var button : PackedScene

@onready var traverseButtons = $TraverseButtons

var currentLocation = null

func start_turn():
	create_buttons()

#Takes a MapPath node, and moves the player along it
func traverse(Node):
	pass

#Create a button for each path from the current node
func create_buttons():
	if !currentLocation:
		return
	for path in currentLocation.paths:
		var newButton = button.instantiate()
		traverseButtons.add_child(newButton)
		newButton.global_position = global_position
		newButton.global_position.y += 2
		newButton.look_at(path.to.global_position, Vector3.UP)
		#newButton.global_position.x += 3
		newButton.rotation.x = 0
		newButton.rotation.z = 0
	pass
