extends Node3D

@onready var sceneChanger = $SceneChanger
@onready var network = $Network

var inGame = false
var currentScene = null
#var players : Node = null

func _ready():
	currentScene = sceneChanger.change_scene(sceneChanger.mainMenu)
	currentScene.open_lobby.connect(open_lobby)
	pass

func open_lobby(host : bool):
	print("opening lobby")
	var currentScene = sceneChanger.change_scene(sceneChanger.lobby)
	#players = lobby.playerContainer
	currentScene.start_game.connect(start_game)
	currentScene.close_lobby.connect(close_lobby)
	network.player_joined.connect(currentScene.player_joined)
	network.player_left.connect(currentScene.player_left)
	
	if !host:
		network.join_server()
		await network.peers_synced
		currentScene.initialize(network.peers)
	else:
		network.create_server()
		currentScene.initialize()
	pass

func close_lobby(error : int = 1):
	currentScene = sceneChanger.change_scene(sceneChanger.mainMenu)
	pass

@rpc
func start_game(playerCount : int):
	print("starting game with ", playerCount, " players")
	var currentScene = sceneChanger.change_scene(sceneChanger.game)
	if network.peers.size() > 0:
		currentScene.start_game(network.peers)
		rpc("start_game", playerCount)
	else:
		currentScene.start_game([1])
	inGame = true
	
func host_game():
	network.create_server()
	open_lobby(true)
	
func join_game():
	network.join_server()
	await network.peers_synced
	open_lobby(false)
