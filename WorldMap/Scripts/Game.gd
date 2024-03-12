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
signal received_action()
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

	currentPlayer = players.get_child(0)
	
	#Make sure all of the clients are ready to proceed
	if ID == 1:
		rpc("set_ready", ID)
		ready_check()
	else:
		await ready_check.call_deferred()
	
	while !finished:
		timer.wait_time = 0.25
		timer.start()
		await timer.timeout
		
		if ID == 1:
			#Insert dice roll here
			moveCount = randi_range(1, 6)
		else:
			#Request a turn sync from the host
			print(ID, ": requesting sync")
			request_sync.rpc_id(1, ID)
			await turn_synced
			#print("after turn sync")
			
		start_turn(currentPlayer)
		if currentPlayer.ID == ID:
			
			#Connect the player signals to the UI, and the end turn button to the player
			currentPlayer.moveCountChanged.connect(UI.set_moves)
			UI.endTurn.connect("pressed", currentPlayer.end_turn)
			await currentPlayer.turnFinished
			#Disconnect the UI from the player after the player is done
			currentPlayer.moveCountChanged.disconnect(UI.set_moves)
			UI.endTurn.disconnect("pressed", currentPlayer.end_turn)
			
			UI.clear_moves()
			action = currentPlayer.get_action()
			
			if ID != 1:
				send_action.rpc_id(1, ID, action)
		
		if ID == 1 && currentPlayer.ID != 1:
			await received_action
			#Error checking here
			evaluate_action(currentPlayer.ID, action)
			rpc("evaluate_action", currentPlayer.ID, action)
		elif ID == 1:
			evaluate_action(currentPlayer.ID, action)
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
		player.moves = 0
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
	print(ID, ": action evaluated")
	action_evaluated.emit()
	
	pass

@rpc("any_peer", "reliable")
func send_action(senderID, action):
	print(ID, ": received")
	if currentPlayer.ID == senderID:
		self.action = action
		print(self.action)
	received_action.emit()
	

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

@rpc("any_peer", "reliable")
func request_sync(senderID):
	#Sent to the host to request turn data
	rpc_id(senderID, "sync_turn", currentPlayer.ID, moveCount)
	readyList[senderID] = true

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
	if check_readyList(): 
		#print(ID, ": emitting ready")
		ready_signal.emit()

@rpc("reliable")
func send_readyList(readyList : Dictionary):
	#Function for the host to send the readyList to clients
	#print(ID, ": receiving ready list")
	for item in readyList:
		var value = readyList[item]
	self.readyList = readyList
	
	if check_readyList():
		ready_signal.emit()
	pass

func ready_check():
	if !check_readyList():
		await ready_signal
	unset_ready()

func check_readyList() -> bool:
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
