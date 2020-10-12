extends Node

# global state variables
var paused = false 
var routes = {
		'Menus' : {'active' : true, 'path': 'res://Views/Menus.tscn'}, 
		'GrassVillage' : {'active' : false, 'path' : 'res://Levels/GrassVillage.tscn'} 
	}

# nodes
onready var menus = get_node("/root/Menus")

# global functions
func change_scene_to(scene):
	var error = get_tree().change_scene(routes[scene].path)
	if(error):
		print(error)

func load_level(level):
	var scene = load(routes[level].path).instance()
	get_node("/root").add_child(scene)
	menus.hide_all()

func unload_level(level, menu):
	get_node("/root/" + level).queue_free()
	menus.show_menu(menu)

func exit_game():
	get_tree().quit()

func get_route_path(route):
	return routes[route].path
# global utils
