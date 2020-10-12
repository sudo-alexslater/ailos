extends CanvasLayer

onready var pause_menu = $PauseScreen

func _unhandled_input(event):
	if(event is InputEventKey):
		if(event.pressed and event.scancode == KEY_ESCAPE):
			pause_menu.toggle_view()

func _ready():
	$MultiplayerLobby.show_view()
	print('Menus Ready')

func update_view():
	$MultiplayerLobby.update_lobby_list()

func hide_all():
	for node in get_children():
		node.hide_view()

func show_menu(menu_name):
	get_node(menu_name).show_view()
