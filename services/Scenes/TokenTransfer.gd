extends Node

var network: NetworkedMultiplayerENet
var m_api: MultiplayerAPI
var ip = "127.0.0.1"
var port = 2003

func _ready() -> void:
	_create_network_api()

func _process(delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func _create_network_api():
	network = NetworkedMultiplayerENet.new()
	m_api = MultiplayerAPI.new()
	network.create_client(ip, port)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed() -> void:
	print("connection to Authentication Server failed")

func _on_connection_succeeded() -> void:
	print("connection to Authentication Server succeeded")

remote func receive_token(token: String, username: String) -> void:
	PlayerVerification.add_token(token, username)
