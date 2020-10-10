extends Control

onready var network = get_node('/root/Networking');
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