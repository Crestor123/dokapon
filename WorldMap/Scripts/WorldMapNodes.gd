extends Node3D

@export var MapLocation : PackedScene
@export var MapPath : PackedScene
@export var WorldMap : Map 
@export var Player : PackedScene

var homeNode = null

func _ready():
	#var newLocation = MapLocation.instantiate()
	#add_child(newLocation)
	#initialize_map()
	#test()
	pass

func initialize_map():
	for node in WorldMap.nodes:
		var newLocation = MapLocation.instantiate()
		add_child(newLocation)
		newLocation.position = node.position
		newLocation.locationName = node.name
		if node.name == "Home":
			homeNode = newLocation

	var i = 0
	for list in WorldMap.edges:
		var from = get_child(i)
		for edge in list.to:
			var to = get_child(edge)
			var newEdge = MapPath.instantiate()
			from.edges.add_child(newEdge)
			from.paths.append(newEdge)
			to.paths.append(newEdge)
			newEdge.initialize(to)
		i += 1

func test():
	for location in get_children():
		print(location.locationName)
		for path in location.paths:
			if (location == path.from):
				print(" Edge to " + path.to.locationName)
			else:
				print(" Edge from " + path.from.locationName)
	pass
