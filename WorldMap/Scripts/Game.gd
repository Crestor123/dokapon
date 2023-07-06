extends Node3D

@onready var locations = $Locations
@onready var players = $Players
@onready var UI = $UILayer
@onready var timer = $Timer

var main : Node = null
var hostPlayer = null
var currentPlayer = null
var finished = false

signal game_started()
signal turn_start(player)
signal turn_end()

#func _ready():
	#locations.initialize_map()
	#players.initialize_players(locations.homeNode)
	#hostPlayer = players.get_child(0)
	#start_game()

func set_main(node : Node):
	main = node

func start_game(playerIds : Array):
	locations.initialize_map()
	players.initialize_players(playerIds, locations.homeNode)
	#hostPlayer = players.get_child(0)
	currentPlayer = players.get_child(0)
	if multiplayer.get_unique_id() == 1:
		rpc("sync_turn", currentPlayer.ID)
	while !finished:
		await start_turn()

func start_turn():
	#print(multiplayer.get_unique_id(), ": start of turn loop")
	print(multiplayer.get_unique_id(), ": ", currentPlayer.ID, "'s turn")
	#print("starting turn")
	#if multiplayer.get_unique_id() != 1:
		#await turn_start
	if multiplayer.get_unique_id() == 1:
		pass
		#turn_start.emit(currentPlayer)
		#print("syncing turn")
		#rpc("sync_turn", currentPlayer.ID)
		#print(multiplayer.get_unique_id(), ": ", currentPlayer.ID, "'s turn")
	if currentPlayer.ID == multiplayer.get_unique_id():
		currentPlayer.start_turn()
		print(multiplayer.get_unique_id(), ": starting turn")
		UI.endTurn.show()
		await currentPlayer.turnFinished
	else:
		#print(multiplayer.get_unique_id(), ": awaiting turn end")
		UI.endTurn.hide()
		await turn_end
		
	await rpc("end_turn", currentPlayer.ID)
	#if multiplayer.get_unique_id() == 1:
		#currentPlayer = players.get_next_player(currentPlayer)

func evaluate_action():
	pass

@rpc("call_local")
func end_turn(playerID):
	#print("ending turn")
	print(multiplayer.get_unique_id(), ": ending turn for ", playerID)
	UI.endTurn.hide()
	timer.wait_time = 2
	timer.start()
	await timer.timeout
	turn_end.emit()
	if multiplayer.get_unique_id() == 1:
		currentPlayer = players.get_next_player(currentPlayer)
		print("syncing turn")
		rpc("sync_turn", currentPlayer.ID)
	pass

func update_location_UI(data):
	UI.setLocation(data[0], data[1])

@rpc
func sync_turn(newCurrentPlayerID):
	for child in players.get_children():
		if child.ID == newCurrentPlayerID:
			currentPlayer = child
	#print("current player: " , currentPlayer.ID)
	turn_start.emit(currentPlayer)
