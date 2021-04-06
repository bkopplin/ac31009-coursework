extends Node

var network = NetworkedMultiplayerENet.new()
var port = 2001
var max_clients = 10

func _ready() -> void:
	network.create_server(port, max_clients)
	get_tree().set_network_peer(network)
	
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")	

func _on_peer_connected(client_id) -> void:
	print(client_id + " connected")

func _on_peer_disconnected(client_id) -> void:
	print (client_id + " disconnected")


remote func login_request(username: String, password: String, player_id: int) -> void:
	pass

remote func signup_request(options: Directory, player_id: int) -> void:
	$PlayerAuthentication.create_account(options)

func _generate_random_token() -> String:
	randomize()
	return str(randi()).sha256_text() + str(OS.get_system_time_secs())
