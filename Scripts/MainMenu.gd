extends Node3D

@onready var startButton = $CanvasLayer/CenterContainer/VBoxContainer/Button
@onready var main

signal startGame(playerCount : int)

func set_main(mainNode : Node):
	main = mainNode
	#main.start_game()
	#connect("startGame", main._start_game)

func _on_button_pressed():
	print("starting game")
	main.start_game(1)


func _on_button_2_pressed():
	print("starting game with 2 players")
	main.start_game(2)

func _on_host_pressed():
	main.host_game()

func _on_join_pressed():
	main.join_game()
