extends Node3D

@onready var locations = $Locations
@onready var players = $Players
@onready var UI = $UILayer

var hostPlayer = null
var currentPlayer = null

func _ready():
	locations.initialize_map()
	players.initialize_players(locations.homeNode)
	hostPlayer = players.get_child(0)
	start_game()

func start_game():
	currentPlayer = players.get_child(0)
	currentPlayer.start_turn()

func update_location_UI(data):
	UI.setLocation(data[0], data[1])
