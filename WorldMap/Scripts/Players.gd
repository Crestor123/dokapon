extends Node3D

@export var Player : PackedScene

var homeNode = null
var host = null

func new_player(id):
	initialize_players([id], homeNode)

func initialize_players(ids : Array, home : Node):
	homeNode = home
	for i in ids:
		var player = Player.instantiate()
		add_child(player)
		if i == 1:
			host = player
		player.ID = i
		player.currentLocation = home
		player.global_position = home.global_position

func get_next_player(currentPlayer : Node):
	var nextPlayerIndex = (currentPlayer.get_index() + 1) % get_child_count()
	var nextPlayer = get_child(nextPlayerIndex)
	return nextPlayer
