extends Node3D

@onready var sceneChanger = $SceneChanger
@onready var network = $Network

var inGame = false
var players : Node = null

func _ready():
	sceneChanger.change_scene(sceneChanger.mainMenu)
	pass

func start_game(playerCount : int):
	print("starting game with ", playerCount, " players")
	var gameScene = sceneChanger.change_scene(sceneChanger.WorldMap)
	players = gameScene.players
	network.set_player_node(players)
	gameScene.start_game(playerCount)
	inGame = true
	
func host_game():
	network.create_server()
	start_game(1)
	
func join_game():
	network.join_server()
	start_game(1)
