extends Node

# nodes
onready var SERVER_IP = $Columns/InputSection/Rows/IPInput
onready var SERVER_PORT = $Columns/InputSection/Rows/PortInput
onready var NAME = $Columns/InputSection/Rows/NameInput

# network variables
var player_info = {}
var my_info = { name = 'slater-duud' }

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func start_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(int(SERVER_PORT.get_text()), 10)
	get_tree().network_peer = peer
	my_info.name = NAME.get_text()

func start_client():
	var peer = NetworkedMultiplayerENet.new()
	print("Attempting connection to: ", SERVER_IP.get_text(), ":", SERVER_PORT.get_text())
	peer.create_client(SERVER_IP.get_text(), int(SERVER_PORT.get_text()))
	get_tree().network_peer = peer
	my_info.name = NAME.get_text()

func stop_networking():
	get_tree().network_peer = null

func start_game(): 
	rpc("pre_configure_game")

func _connected_ok():
	print('Connected')

func _server_disconnected():
	pass

func _connected_fail():
	print('Connection Failed')
	stop_networking()

func _player_connected(id):
	print(id)
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	player_info.erase(id)

func regenerate_lobby_list():
	# clear lobby list
	for node in get_node("/root/HostOrJoinServer/Columns/PlayerLobbySection/Rows").get_children():
		node.queue_free()
	# add current user
	var label = preload('res://ViewComponents/PlayerLobbyLabel.tscn').instance()
	label.text = my_info.name
	get_node("/root/HostOrJoinServer/Columns/PlayerLobbySection/Rows").add_child(label)
	# regenerate lobby list
	for player in player_info:
		var others_label = preload('res://ViewComponents/PlayerLobbyLabel.tscn').instance()
		others_label.text = player.name
		get_node("/root/HostOrJoinServer/Columns/PlayerLobbySection/Rows").add_child(others_label)
	

remotesync func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = info
	regenerate_lobby_list()

remotesync func pre_configure_game():
	get_tree().paused = true
	var selfPeerID = get_tree().get_network_unique_id()
	# load world
	var level = load('res://Levels/TestPlayground.tscn').instance()
	get_node("/root").add_child(level)

	# load self player
	var my_player = preload("res://Characters/Player.tscn").instance()
	my_player.name = str(selfPeerID)
	my_player.set_network_master(selfPeerID)
	get_node('/root/TestPlayground').add_child(my_player)

	# load other players
	for p in player_info:
		var player = preload("res://Characters/Player.tscn").instance()
		player.get_child(0).queue_free()
		player.name = str(p)
		player.set_network_master(p)
		get_node('/root/TestPlayground').add_child(player)
		
	rpc_id(1, "done_preconfig")

var players_done = []

remotesync func done_preconfig():
	var who = get_tree().get_rpc_sender_id()
	players_done.append(who)

	if(players_done.size() - 1 == player_info.size()):
		rpc("post_configure_game")

remotesync func post_configure_game():
	if(get_tree().get_rpc_sender_id() == 1):
		get_tree().paused = false
	# delete menu
	$Columns.hide()
