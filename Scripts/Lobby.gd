extends Node3D

@onready var playerContainer = $CanvasLayer/HBoxContainer/VBoxContainer
@onready var players = playerContainer.get_children() 

signal start_game(playerCount)
signal close_lobby(error)

var main : Node = null

func set_main(mainNode):
	main = mainNode

func initialize(playerList = null):
	if playerList:
		#await get_tree().create_timer(1).timeout
		print(playerList, " already connected")
		players[0].text = "Host"
		players[1].text = "ID: " + str(playerList[1])
	else:
		players[0].text = "You: ID 1"
	pass

func player_joined(peerId):
	print("lobby: player ", peerId, " joined")
	players[1].text = "ID: " + str(peerId)
	pass

func player_left(peerId):
	print("lobby: player ", peerId, " left")
	if peerId == 1:
		print("closing lobby")
		close_lobby.emit()
	for child in players:
		if child.text == "ID: " + str(peerId):
			child.text = "Empty Slot"

func _on_button_pressed():
	start_game.emit(players.size())
