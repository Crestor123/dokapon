extends StaticBody3D

@onready var edges = $Edges
@onready var button = $Button3D

var locationName : String
var paths : Array[Node]
var type : String
