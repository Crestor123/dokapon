extends Node3D

@onready var mapNodes = $MapNodes
@onready var players = $Players

func _ready():
	mapNodes.initialize_map()
	players.initialize_players(mapNodes.homeNode)
	players.get_child(0).start_turn()
