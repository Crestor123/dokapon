extends Node3D

@export var Player : PackedScene

var playerName : String = "player"
var playerClass : String = "none"
var level : int = 0

var coins : int = 0

func initialize_players(playerCount : int, home : Node):
	for i in range(playerCount):
		var player = Player.instantiate()
		add_child(player)
		player.currentLocation = home
		player.global_position = home.global_position

func get_next_player(currentPlayer : Node):
	var nextPlayerIndex = (currentPlayer.get_index() + 1) % get_child_count()
	var nextPlayer = get_child(nextPlayerIndex)
	return nextPlayer
