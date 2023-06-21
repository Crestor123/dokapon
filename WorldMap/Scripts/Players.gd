extends Node3D

@export var Player : PackedScene

var playerName : String = "player"
var playerClass : String = "none"
var level : int = 0

var coins : int = 0

func initialize_players(home : Node):
	var player = Player.instantiate()
	add_child(player)
	player.currentLocation = home
	player.global_position = home.global_position
