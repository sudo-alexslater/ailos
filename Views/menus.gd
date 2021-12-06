extends CanvasLayer

onready var pause_menu = $PauseScreen

var active_menu

func _unhandled_input(event):
	if(event is InputEventKey):
		if(event.pressed):
			if(event.scancode == KEY_ESCAPE):
				if(active_menu):
					active_menu.hide_view()
					active_menu = null
				else:
					pause_menu.toggle_view()

func _ready():
	$MultiplayerLobby.show_view()
	print('Menus Ready')

func update_view():
	$MultiplayerLobby.update_lobby_list()

func hide_all():
	for node in get_children():
		node.hide_view()

func show_menu(menu_name, menu_options=null):
	var menu = get_node(menu_name)
	active_menu = menu
	menu.show_view()
	if(menu_options):
		menu.apply_state(menu_options)

