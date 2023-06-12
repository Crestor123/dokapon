extends Node3D

@export var MapLocation : PackedScene

func _ready():
	var newLocation = MapLocation.instantiate()
	add_child(newLocation)
	pass
