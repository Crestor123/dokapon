extends CharacterBody3D

@export var button : PackedScene

@onready var traverseButtons = $TraverseButtons

var ID : int

var currentLocation = null
var nextLocation = null

var t = 0.0

signal turnFinished(action)
signal moveFinished()
signal moveCountChanged(moves)

var playerName : String = "player"
var playerClass : String = "none"
var level : int = 0

var coins : int = 0

var moves : int = 0
var action = []

func _ready():
	name = str(get_multiplayer_authority())

func _physics_process(delta):
	if nextLocation != null:
		t += delta
		transform = currentLocation.transform.interpolate_with(nextLocation.transform, t)
		if transform == nextLocation.transform:
			currentLocation = nextLocation
			nextLocation = null
			
			await get_tree().create_timer(0.2).timeout
			
			moveFinished.emit()
			
			if moves > 0: create_buttons()
	else:
		t = 0.0
	
	pass

func start_turn(moveCount : int):
	moves = moveCount
	action.clear()
	create_buttons()

func get_action():
	return action

#Takes a MapPath node, and moves the player along it
func traverse(location : Node):
	nextLocation = location
	action.append(["move", location.locationName])
	moves = moves - 1
	moveCountChanged.emit(moves)
	delete_buttons()
	
	pass

#Create a button for each path from the current node
func create_buttons():
	#If the player has no moves remaining, don't create any buttons
	if moves <= 0: return
	
	if !currentLocation:
		return
		
	for path in currentLocation.paths:
		var newButton = button.instantiate()
		var buttonPosition : Vector3
		traverseButtons.add_child(newButton)
		newButton.global_position = global_position
		newButton.global_position.y += 1.1

		newButton.buttonPressed.connect(traverse)
		
		if currentLocation == path.from:
			newButton.data = path.to
			newButton.look_at(path.to.global_position, Vector3.UP)
			traverseButtons.look_at(path.to.global_position, Vector3.UP)
		else:
			newButton.data = path.from
			newButton.look_at(path.from.global_position, Vector3.UP)
			traverseButtons.look_at(path.from.global_position, Vector3.UP)
			
		newButton.position.z = -2
		buttonPosition = newButton.global_position
		traverseButtons.rotation.y = 0
		newButton.global_position = buttonPosition
	pass

func delete_buttons():
	for child in traverseButtons.get_children():
		child.queue_free()

func end_turn():
	delete_buttons()
	turnFinished.emit()
	pass
