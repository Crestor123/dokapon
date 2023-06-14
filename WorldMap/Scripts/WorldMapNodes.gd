extends Node3D

@export var MapLocation : PackedScene
@export var MapPath : PackedScene
@export var WorldMap : Map 

func _ready():
	#var newLocation = MapLocation.instantiate()
	#add_child(newLocation)
	initialize_map()
	pass

func initialize_map():
	for node in WorldMap.nodes:
		var newLocation = MapLocation.instantiate()
		add_child(newLocation)
		newLocation.position = node.position

	var i = 0
	for list in WorldMap.edges:
		var from = get_child(i)
		for edge in list.to:
			var to = get_child(edge)
			var newEdge = MapPath.instantiate()
			from.edges.add_child(newEdge)
			var angle = from.global_position.angle_to(to.global_position)
			var distance = from.global_position.distance_to(to.global_position)
			newEdge.look_at(to.global_position, Vector3.UP)
			newEdge.global_position.x = (to.global_position.x + from.global_position.x) / 2
			newEdge.global_position.z = (to.global_position.z + from.global_position.z) / 2
			newEdge.scale.z = distance
