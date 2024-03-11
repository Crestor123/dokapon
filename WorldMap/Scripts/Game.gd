extends Node3D

@onready var locations = $Locations
@onready var players = $Players
@onready var UI = $UILayer
@onready var timer = $Timer

var main : Node = null
var ID = null
var hostPlayer = null
var currentPlayer = null
var readyList = {}
var moveCount : int = 0
var finished = false

var action = null

signal game_started()
signal turn_start(player)
signal turn_end()
signal ready_signal()
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
	ID = multiplayer.get_unique_id()
	
	locations.initialize_map()
	
	#Generate a list to contain the ready states of all peers
	for ID in playerIDs:
		readyList[ID] = false
	
	players.initialize_players(playerIDs, locations.homeNode)
	#hostPlayer = players.get_child(0)
	currentPlayer = players.get_child(0)
	#if multiplayer.get_unique_id() == 1:
	
	#Ready check
	rpc("set_ready", ID)
	if !ready_check():
		await ready_signal
	
	while !finished:
		if multiplayer.get_unique_id() == 1:
			timer.wait_time = 0.25
			timer.start()
			await timer.timeout
			moveCount = randi_range(1, 6)
			
			rpc("sync_turn", currentPlayer.ID, moveCount)
		else:
			await turn_synced
			print("after turn sync")
		start_turn(currentPlayer)
		if currentPlayer.ID == ID:
			
			currentPlayer.moveCountChanged.connect(UI.set_moves)
			UI.endTurn.connect("pressed", currentPlayer.end_turn)
			await currentPlayer.turnFinished
			currentPlayer.moveCountChanged.disconnect(UI.set_moves)
			UI.endTurn.disconnect("pressed", currentPlayer.end_turn)
			
			UI.clear_moves()
			var action = currentPlayer.get_action()
			#evaluate_action(currentPlayer.ID, action)
			#Need to wait for all clients to be ready
			rpc("evaluate_action", currentPlayer.ID, action)
		else:
			await action_evaluated
		await end_turn(currentPlayer.ID)
		currentPlayer = players.get_next_player(currentPlayer)

func start_turn(player):
	#print(multiplayer.get_unique_id(), ": start of turn loop")
	UI.set_turn(str(player.ID))
	print(ID, ": ", player.ID, "'s turn")
	
	
	#print("starting turn")
	#if multiplayer.get_unique_id() != 1:
		#await turn_start
	if ID == 1:
		pass
		#turn_start.emit(currentPlayer)
		#print("syncing turn")
		#rpc("sync_turn", currentPlayer.ID)
		#print(multiplayer.get_unique_id(), ": ", currentPlayer.ID, "'s turn")
	if player.ID == ID:
		#Have the dice show the current move count, simulating a roll
		
		UI.set_moves(moveCount)
		
		player.start_turn(moveCount)
		print(ID, ": starting turn")
		UI.endTurn.show()
		#await currentPlayer.turnFinished
	else:
		#print(multiplayer.get_unique_id(), ": awaiting turn end")
		UI.endTurn.hide()
		#await turn_end
	#if multiplayer.get_unique_id() == 1:
		#currentPlayer = players.get_next_player(currentPlayer)

#Processes the action performed by the player and relays it to the other clients
@rpc('any_peer', "reliable")
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
					break
			await actingPlayer.moveFinished
	print(ID, ": evaluating action")
	action_evaluated.emit()
	
	pass

@rpc("call_local", "reliable")
func end_turn(playerID):
	#print("ending turn")
	print(ID, ": ending turn for ", playerID)
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
	UI.set_location(data[0], data[1])

@rpc("reliable")
func sync_turn(newCurrentPlayerID, moveCount):
	print("syncing turns")
	self.moveCount = moveCount
	
	for child in players.get_children():
		if child.ID == newCurrentPlayerID:
			currentPlayer = child
	#print("current player: " , currentPlayer.ID)
	turn_start.emit(currentPlayer)
	turn_synced.emit()

@rpc("call_local", "any_peer", "reliable")
func set_ready(senderID):
	#Called from peers as part of a ready check
	print(ID, ": ", senderID, " is ready")
	readyList[senderID] = true
	
	#When the host gets a confirmation, send out the host's list to the client
	if ID == 1 && senderID != 1:
		print("sending ready list to ", senderID)
		rpc_id(senderID, "send_readyList", readyList)
	
	#Once all peers are ready, emit a ready signal
	if ready_check(): 
		print(ID, ": emitting ready")
		ready_signal.emit()

@rpc("reliable")
func send_readyList(readyList : Dictionary):
	#Function for the host to send the readyList to clients
	print(ID, ": receiving ready list")
	for item in readyList:
		var value = readyList[item]
		print(item, ": ", value)
	self.readyList = readyList
	
	if ready_check():
		ready_signal.emit()
	pass

func ready_check() -> bool:
	#Check if all of the clients are ready
	for item in readyList:
		var value = readyList[item]
		if value == false: return false
	return true

func unset_ready():
	#Set all of the clients back to unready
	for item in readyList:
		var value = readyList[item]
		value = false
