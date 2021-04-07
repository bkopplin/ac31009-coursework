extends Node

var network = NetworkedMultiplayerENet.new()
var m_api = MultiplayerAPI.new()
var port = 2002
var maxplayers = 200
onready var tree: SceneTree = get_tree()

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
	PlayerManager.player_disconnected(client_id)

remote func verify(token: String, username: String) -> void:
	var player_id = custom_multiplayer.get_rpc_sender_id()
#	print("received token=" + token + ", username=" + username)
	var verified = PlayerVerification.verify(token, username)
	if verified:
		print(username + " verified.")
		print("in verify player id: " + str(player_id))
		PlayerManager.player_connected(username, player_id)
	rpc_id(player_id, "return_verification_result", verified)


func update_available_players() -> void:
	var p = PlayerManager.get_available_users()
	rpc_id(0, "update_available_players", p)

remote func fetch_available_players() -> void:
	print("fetch_available_players")
	var client_id = custom_multiplayer.get_rpc_sender_id()
	var p = PlayerManager.get_available_users()
	rpc_id(client_id, "update_available_players", p)
