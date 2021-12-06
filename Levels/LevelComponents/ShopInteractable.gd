extends StaticBody2D


# onready vars

onready var interact_radius = $InteractRadius
onready var menus = get_node('/root/GameStateManager').menus

# state vars

var menu_options = {
	player = null,
	shop_items = [
		{icon = 'res://icon.png', text = 'Master Sword', id = 'master-sword-item', price = 50}, 
		{icon = 'res://icon.png', text = 'Slave Sword', id = 'slave-sword-item', price = 30},
		{icon = 'res://icon.png', text = 'Peasant Sword', id = 'peasant-sword-item', price = 23}
	]
}

func _ready():
	set_meta('type', 'interactable');

func interact(player):
	menu_options.player = player
	menus.show_menu('ShopDialog', menu_options)
