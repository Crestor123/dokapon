extends Node3D

@onready var locations = $Locations
@onready var players = $Players
@onready var UI = $UILayer
@onready var timer = $Timer

var main : Node = null
var hostPlayer = null
var currentPlayer = null
var finished = false

#func _ready():
	#locations.initialize_map()
	#players.initialize_players(locations.homeNode)
	#hostPlayer = players.get_child(0)
	#start_game()

func set_main(node : Node):
	main = node

func start_game(playerCount : int):
	locations.initialize_map()
	players.initialize_players(playerCount, locations.homeNode)
	hostPlayer = players.get_child(0)
	currentPlayer = players.get_child(0)
	start_turn()

func start_turn():
	while !finished:
		#print("starting turn")
		currentPlayer.start_turn()
		if currentPlayer == hostPlayer:
			UI.endTurn.show()
		else:
			UI.endTurn.hide()
		pass
		await currentPlayer.turnFinished
		await end_turn()

func evaluate_action():
	pass
	
func end_turn():
	#print("ending turn")
	UI.endTurn.hide()
	timer.wait_time = 2
	timer.start()
	await timer.timeout
	currentPlayer = players.get_next_player(currentPlayer)
	pass

func update_location_UI(data):
	UI.setLocation(data[0], data[1])
