extends Node3D

@export var Player : PackedScene

var homeNode = null

func new_player():
	initialize_players(1, homeNode)

func initialize_players(playerCount : int, home : Node):
	homeNode = home
	for i in range(playerCount):
		var player = Player.instantiate()
		add_child(player)
		player.currentLocation = home
		player.global_position = home.global_position

func get_next_player(currentPlayer : Node):
	var nextPlayerIndex = (currentPlayer.get_index() + 1) % get_child_count()
	var nextPlayer = get_child(nextPlayerIndex)
	return nextPlayer
