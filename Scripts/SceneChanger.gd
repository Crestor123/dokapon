extends Node

@export var mainMenu : PackedScene
@export var worldMap : PackedScene
@export var lobby : PackedScene


func change_scene(scene : PackedScene):
	if get_child_count() > 0:
		get_child(0).queue_free()
	var newScene = scene.instantiate()
	add_child(newScene)
	print("setting up new scene")
	newScene.set_main(get_parent())
	return newScene
	pass
