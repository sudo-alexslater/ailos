extends Control

onready var shop_item_list = $ItemList

var interacting_player

func _ready():
	pass

func show_view():
	visible = true

func hide_view():
	visible = false

func apply_state(state):
	shop_item_list.clear()

	interacting_player = state.player

	for n in state.shop_items:
		var texture = load(n.icon)
		shop_item_list.add_item(n.text + ' $' + str(n.price), texture, true)

func _on_Button_pressed():
	interacting_player.recieve_items(shop_item_list.get_selected_items(), 50)
	pass
