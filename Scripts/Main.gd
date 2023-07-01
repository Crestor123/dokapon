extends Node3D

@onready var sceneChanger = $SceneChanger

func _ready():
	sceneChanger.change_scene(sceneChanger.mainMenu)
	pass

func start_game(playerCount : int):
	print("starting game with ", playerCount, " players")
	var gameScene = sceneChanger.change_scene(sceneChanger.WorldMap)
	gameScene.start_game(playerCount)
	
