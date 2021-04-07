extends Node

var network = NetworkedMultiplayerENet.new()
var port = 2001
var max_clients = 10
onready var tree: SceneTree = get_tree()
onready var auth_helper = get_node("AuthHelper")

func _ready() -> void:
	network.create_server(port, max_clients)
	get_tree().set_network_peer(network)
	
	print("server listening on port " + str(port))
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")	

func _on_peer_connected(client_id) -> void:
	print(str(client_id) + " connected")

func _on_peer_disconnected(client_id) -> void:
	print (str(client_id) + " disconnected")


remote func login_request(username: String, password: String, player_id: int) -> void:
	var auth: bool = auth_helper.authenticate(username, password)
	var token = auth_helper.generate_random_token() if auth else ""
	rpc_id(tree.get_rpc_sender_id(), "return_login_results", token, auth, player_id)
	# TODO send token to Services

remote func signup_request(options: Dictionary, player_id: int) -> void:
	var client_id = tree.get_rpc_sender_id()
	print("received signup request")
	var result = auth_helper.create_account(options)
	var token = auth_helper.generate_random_token() if result else ""
	rpc_id(client_id, "return_signup_results", token, result, player_id)
	# TODO send token to Services


