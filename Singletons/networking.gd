extends Node

# onready refs

onready var menus = get_node('/root/Menus')
onready var game_state_manager = get_node('/root/GameStateManager')
onready var player_node = preload("res://Entities/Characters/BasicPlayer.tscn");

# network variables

var player_info = {}
var players_done = []
var my_info = { name = 'slater-duud', killed = false }
puppetsync var game_started = false

# state vars

var loaded_level


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func start_server(port, name):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, 10)
	get_tree().network_peer = peer
	var selfPeerID = get_tree().get_network_unique_id()

	print('Attempting to create Server on port: ', port)

	my_info.name = name
	player_info[selfPeerID] = my_info
	menus.update_view()

func start_client(ip, port, name):
	var peer = NetworkedMultiplayerENet.new()

	print("Attempting connection to: ", ip, ":", port)

	peer.create_client(ip, int(port))
	get_tree().network_peer = peer

	my_info.name = name
	menus.update_view()

func stop_networking():
	if(get_tree().network_peer):
		print('Resetting network..')
		get_tree().network_peer = null

		# if game has started free the loaded level
		if(game_started):
			loaded_level.queue_free()

		reset_network_variables()

		menus.show_menu('MultiplayerLobby')
		menus.update_view()

func reset_network_variables():
	player_info = {}
	game_started = false
	players_done = []

func start_game(): 
	if(get_tree().network_peer):
		rpc("pre_configure_game")

func _connected_ok():
	rpc_id(1, 'register_player', my_info)
	print('Connected')

func _server_disconnected():
	print('Kicked by Server')
	stop_networking()

func _connected_fail():
	print('Connection Failed')
	stop_networking()

func _player_connected(id):
	print('Player joined lobby')
	if(game_started):
		render_player(id)
		if(get_tree().is_network_server()):
			hot_join_player(id)

func _player_disconnected(id):
	print('Player left lobby')
	player_info.erase(id)
	if(game_started):
		if(!player_info[int(id)].killed):
			get_node(loaded_level.path + str(id)).queue_free()

func hot_join_player(id):
	rpc_id(id, 'hot_join', player_info)
	rset_id(id, 'game_started', true)

remote func hot_join(remote_player_info):
	player_info = remote_player_info
	load_game(false)

func player_killed(id):
	player_info[id].killed = true
	print(player_info[id], " killed")
	rpc('update_player_info', player_info)
	
func get_player_name(id):
	return player_info[int(id)].name
	
remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = info
	menus.update_view()
	rpc('update_player_info', player_info)

remote func update_player_info(remote_player_info):
	player_info = remote_player_info
	menus.update_view()

remotesync func pre_configure_game():
	load_game(true)
	rpc_id(1, "done_preconfig")

func load_game(pause):
	get_tree().paused = pause

	# load world
	# var level = load(game_state_manager.game_config['ServerScenePath']).instance()
	# get_node("/root").add_child(level)
	loaded_level = game_state_manager.load_level(game_state_manager.game_config['ServerScene'], {load = false})
	var selfPeerID = get_tree().get_network_unique_id()

	# load self player
	var my_player = player_node.instance()
	my_player.name = str(selfPeerID)
	my_player.set_network_master(selfPeerID)
	loaded_level.add_child(my_player)

	# load other players
	for p in player_info:
		if(p == selfPeerID): 
			continue
		render_player(p)

func render_player(id):
	var player = player_node.instance()
	# remove camera
	player.get_node("PlayerCamera").queue_free()
	player.name = str(id)
	player.set_network_master(id)
	loaded_level.add_child(player)


remotesync func done_preconfig():
	var who = get_tree().get_rpc_sender_id()
	players_done.append(who)

	if(players_done.size() == player_info.size()):
		rpc("post_configure_game")
		rset("game_started", true)	

remotesync func post_configure_game():
	if(get_tree().get_rpc_sender_id() == 1):
		get_tree().paused = false
		# delete menus
		menus.hide_all()
		print('Starting Game')
