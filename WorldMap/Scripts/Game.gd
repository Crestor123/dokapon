extends Node3D

@onready var locations = $Locations
@onready var players = $Players

func _ready():
	locations.initialize_map()
	players.initialize_players(locations.homeNode)
	players.get_child(0).start_turn()
