extends Control

onready var network = get_node('/root/Networking');
onready var game_state_manager = get_node('/root/GameStateManager')

# nodes
onready var server_ip_input = $Columns/InputSection/Rows/IPInput
onready var server_port_input = $Columns/InputSection/Rows/PortInput
onready var name_input = $Columns/InputSection/Rows/NameInput

func _on_HostButton_pressed():
	network.start_server(int(server_port_input.get_text()), name_input.get_text())

func _on_StartGameButton_pressed():
	network.start_game()

func _on_JoinButton_pressed():
	network.start_client(server_ip_input.get_text(), int(server_port_input.get_text()), name_input.get_text())

func _on_SinglePlayerButton_pressed():
	game_state_manager.load_level('GrassVillage')

func show_view():
	visible = true

func hide_view():
	visible = false

func update_lobby_list():
	if(network.game_started):
		return

	# clear lobby list
	for node in $Columns/PlayerLobbySection/Rows.get_children():
		node.queue_free()

	# regenerate lobby list
	for player in network.player_info:
		var others_label = preload('res://Views/ViewComponents/PlayerLobbyLabel.tscn').instance()
		others_label.text = network.player_info[player].name
		$Columns/PlayerLobbySection/Rows.add_child(others_label)
