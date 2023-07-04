extends Node3D

@onready var sceneChanger = $SceneChanger
@onready var network = $Network

var inGame = false
#var players : Node = null

func _ready():
	sceneChanger.change_scene(sceneChanger.mainMenu)
	pass

func open_lobby(host = true):
	print("opening lobby")
	var lobby = sceneChanger.change_scene(sceneChanger.lobby)
	#players = lobby.playerContainer
	lobby.start_game.connect(start_game)
	network.player_joined.connect(lobby.player_joined)
	if !host:
		lobby.initialize(network.peers)
	else:
		lobby.initialize()
	pass

func start_game(playerCount : int):
	print("starting game with ", playerCount, " players")
	var gameScene = sceneChanger.change_scene(sceneChanger.worldMap)
	#players = gameScene.players
	#network.set_player_node(players)
	gameScene.start_game(playerCount)
	inGame = true
	
func host_game():
	network.create_server()
	open_lobby(true)
	
func join_game():
	network.join_server()
	await network.peers_synced
	open_lobby(false)
