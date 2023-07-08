extends Node3D

@onready var locations = $Locations
@onready var players = $Players
@onready var UI = $UILayer
@onready var timer = $Timer

var main : Node = null
var hostPlayer = null
var currentPlayer = null
var finished = false

var action = null

signal game_started()
signal turn_start(player)
signal turn_end()
signal action_evaluated()
signal turn_synced()

#func _ready():
	#locations.initialize_map()
	#players.initialize_players(locations.homeNode)
	#hostPlayer = players.get_child(0)
	#start_game()

func set_main(node : Node):
	main = node

func start_game(playerIDs : Array):
	locations.initialize_map()
	players.initialize_players(playerIDs, locations.homeNode)
	#hostPlayer = players.get_child(0)
	currentPlayer = players.get_child(0)
	#if multiplayer.get_unique_id() == 1:
		
	while !finished:
		if multiplayer.get_unique_id() == 1:
			timer.wait_time = 0.25
			timer.start()
			await timer.timeout
			rpc("sync_turn", currentPlayer.ID)
		else:
			await turn_synced
			print("after turn sync")
		start_turn(currentPlayer)
		if currentPlayer.ID == multiplayer.get_unique_id():
			await currentPlayer.turnFinished
			var action = currentPlayer.get_action()
			evaluate_action(currentPlayer.ID, action)
			rpc("evaluate_action", currentPlayer.ID, action)
		else:
			await action_evaluated
		await end_turn(currentPlayer.ID)
		currentPlayer = players.get_next_player(currentPlayer)

func start_turn(player):
	#print(multiplayer.get_unique_id(), ": start of turn loop")
	UI.set_turn(str(player.ID))
	print(multiplayer.get_unique_id(), ": ", player.ID, "'s turn")
	#print("starting turn")
	#if multiplayer.get_unique_id() != 1:
		#await turn_start
	if multiplayer.get_unique_id() == 1:
		pass
		#turn_start.emit(currentPlayer)
		#print("syncing turn")
		#rpc("sync_turn", currentPlayer.ID)
		#print(multiplayer.get_unique_id(), ": ", currentPlayer.ID, "'s turn")
	if player.ID == multiplayer.get_unique_id():
		player.start_turn()
		print(multiplayer.get_unique_id(), ": starting turn")
		UI.endTurn.show()
		#await currentPlayer.turnFinished
	else:
		#print(multiplayer.get_unique_id(), ": awaiting turn end")
		UI.endTurn.hide()
		#await turn_end
	#if multiplayer.get_unique_id() == 1:
		#currentPlayer = players.get_next_player(currentPlayer)

#Processes the action performed by the player and relays it to the other clients
@rpc('any_peer')
func evaluate_action(currentPlayerID, action):
	var actingPlayer = null
	for player in players.get_children():
		if player.ID == currentPlayerID:
			actingPlayer = player
	for item in action:
		#Find the location with the same name, and set the player to move toward it
		if item[0] == "move":
			for child in locations.get_children():
				if item[1] == child.locationName:
					actingPlayer.nextLocation = child
	print(multiplayer.get_unique_id(), ": evaluating action")
	action_evaluated.emit()
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
	#if multiplayer.get_unique_id() == 1:
		#currentPlayer = players.get_next_player(currentPlayer)
		#print("syncing turn")
		#rpc("sync_turn", currentPlayer.ID)
	pass

func update_location_UI(data):
	UI.setLocation(data[0], data[1])

@rpc
func sync_turn(newCurrentPlayerID):
	print("syncing turns")
	for child in players.get_children():
		if child.ID == newCurrentPlayerID:
			currentPlayer = child
	#print("current player: " , currentPlayer.ID)
	turn_start.emit(currentPlayer)
	turn_synced.emit()
