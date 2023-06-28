extends CanvasLayer

@onready var coinsLabel = $Coins
@onready var locationLabel = $Panel/VBoxContainer/LocationLabel
@onready var typeLabel = $Panel/VBoxContainer/TypeLabel

func setCoins(amount : int):
	coinsLabel.text = "Coins: " + str(amount)

func setLocation(locationName : String, type : String):
	locationLabel.text = locationName
	typeLabel.text = type
