extends Node3D

@onready var one = $One
@onready var two = $Two
@onready var three = $Three
@onready var four = $Four
@onready var five = $Five
@onready var six = $Six
var sides = [one, two, three, four, five, six]

func top():
	#Returns the value on the top of the dice
	var top = sides[0]
	for side in sides:
		if side.tranform.y > top.transform.y:
			top = side
	return top
	pass
