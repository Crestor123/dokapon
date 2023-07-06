extends Node3D

@onready var startButton = $CanvasLayer/CenterContainer/VBoxContainer/Button
@onready var main
@onready var playerName = $CanvasLayer/CenterContainer/VBoxContainer/TextEdit

signal set_name(playerName : String)
signal open_lobby(host : bool)

func set_main(mainNode : Node):
	main = mainNode
	#main.start_game()
	#connect("startGame", main._start_game)

func _on_button_pressed():
	print("starting game")
	#main.start_game(1)
	open_lobby.emit(true)

func _on_button_2_pressed():
	print("starting game with 2 players")
	#main.start_game(2)
	open_lobby.emit(true)

func _on_host_pressed():
	open_lobby.emit(true)

func _on_join_pressed():
	open_lobby.emit(false)
