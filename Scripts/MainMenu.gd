extends Node3D

@onready var startButton = $CanvasLayer/CenterContainer/VBoxContainer/Button
@onready var main

signal startGame(playerCount : int)

func set_main(mainNode : Node):
	main = mainNode
	#main.start_game()
	connect("startGame", main.start_game)

func _on_button_pressed():
	startGame.emit(1)
