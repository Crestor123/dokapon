extends Node3D

@export var Player : PackedScene

func initialize_players(home : Node):
	var player = Player.instantiate()
	add_child(player)
	player.currentLocation = home
	player.global_position = home.global_position
