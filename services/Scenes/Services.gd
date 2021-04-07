extends Node

var network = NetworkedMultiplayerENet.new()
var m_api = MultiplayerAPI.new()
var port = 2002
var maxplayers = 200
onready var tree: SceneTree = get_tree()

var available_players: Dictionary

func _ready() -> void:
	start_services()

func _process(delta) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func start_services() -> void:
	network.create_server(port, maxplayers)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	print("Services listening on port " + str(port))
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")

func _on_peer_connected(client_id) -> void:
	print(str(client_id) + " connected")

func _on_peer_disconnected(client_id) -> void:
	print (str(client_id) + " disconnected")

remote func push_auth(token: String, username: String) -> void:
	var player_id = tree.get_rpc_sender_id()
	print("received token=" + token + ", username=" + username)
	# if received token in token_list and timestamp is ok, then
	available_players[username] = player_id


