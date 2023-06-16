extends Node3D

@export var MapLocation : PackedScene
@export var MapPath : PackedScene
@export var WorldMap : Map 

func _ready():
	#var newLocation = MapLocation.instantiate()
	#add_child(newLocation)
	initialize_map()
	test()
	pass

func initialize_map():
	for node in WorldMap.nodes:
		var newLocation = MapLocation.instantiate()
		add_child(newLocation)
		newLocation.position = node.position
		newLocation.locationName = node.name

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
			#newEdge.global_position = from.global_position
			#var angle = from.global_position.angle_to(to.global_position)
			#var distance = from.global_position.distance_to(to.global_position)
			#newEdge.look_at(to.global_position, Vector3.UP)
			#newEdge.rotation.x = 0
			#newEdge.rotation.z = 0
			#newEdge.global_position.x = (to.global_position.x + from.global_position.x) / 2
			#newEdge.global_position.z = (to.global_position.z + from.global_position.z) / 2
			#newEdge.scale.z = distance - 2.5
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
