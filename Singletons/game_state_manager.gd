extends Node

# global state variables
var paused = false 
var routes = {
	'Menus' : {'active' : true, 'path': 'res://Views/Menus.tscn'}, 
	'GrassVillage' : {'active' : false, 'path' : 'res://Levels/GrassVillage.tscn'} 
}
var game_config = {
	'ServerScenePath': routes['GrassVillage'].path,
	'ServerScene': 'GrassVillage',
	'MainPlayerPath': 'res://Characters/basic_player.tscn'
}

# nodes
onready var menus = get_node("/root/Menus")
onready var player_node = preload("res://Entities/Characters/BasicPlayer.tscn");

# game scene functions
func change_scene_to(scene):
	var error = get_tree().change_scene(routes[scene].path)
	if(error):
		print(error)

func load_level(level, player_load_data = {load = true, player = player_node, position = Vector2(0, 0)}):
	var scene = load(routes[level].path).instance()
	if(player_load_data.load):
		var player = player_load_data.player.instance()
		player.set_position(player_load_data.position)
		scene.add_child(player)
	get_node("/root").add_child(scene)
	menus.hide_all()
	return scene

func unload_level(level, menu):
	get_node("/root/" + level).queue_free()
	menus.show_menu(menu)

func exit_game():
	get_tree().quit()

func get_route_path(route):
	return routes[route].path
# global utils
