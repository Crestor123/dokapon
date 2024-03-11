extends CanvasLayer

@onready var coinsLabel = $Coins
@onready var locationLabel = $Panel/VBoxContainer/LocationLabel
@onready var typeLabel = $Panel/VBoxContainer/TypeLabel
@onready var turnLabel = $Panel/VBoxContainer/TurnLabel
@onready var moveLabel = $Panel/VBoxContainer/MoveLabel
@onready var endTurn = $Panel/VBoxContainer/EndTurnButton

func set_coins(amount : int):
	coinsLabel.text = "Coins: " + str(amount)

func set_location(locationName : String, type : String):
	locationLabel.text = locationName
	typeLabel.text = type

func set_turn(playerName: String):
	turnLabel.text = playerName + "'s turn"

func set_moves(amount : int):
	moveLabel.text = "Moves: " + str(amount)

func clear_moves():
	moveLabel.text = ""
