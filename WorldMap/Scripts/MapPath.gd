extends Node3D

@export var points : Array[Vector3]
@export var from : Node
@export var to : Node

func initialize(to : Node):
	from = get_parent().get_parent()
	self.to = to
	global_position = from.global_position
	var angle = from.global_position.angle_to(to.global_position)
	var distance = from.global_position.distance_to(to.global_position)
	look_at(to.global_position, Vector3.UP)
	rotation.x = 0
	rotation.z = 0
	global_position.x = (to.global_position.x + from.global_position.x) / 2
	global_position.z = (to.global_position.z + from.global_position.z) / 2
	scale.z = distance - 2.5
