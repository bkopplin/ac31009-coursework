extends Node

var network: NetworkedMultiplayerENet
var m_api: MultiplayerAPI
var ip = "127.0.0.1"
var port = 2003

func _ready() -> void:
	_connect_to_token_transfer()

func _process(delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func _connect_to_token_transfer():
	network = NetworkedMultiplayerENet.new()
	m_api = MultiplayerAPI.new()
	network.create_client(ip, port)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_reconnect")

func _on_connection_failed() -> void:
	print("connection to Authentication Server failed")
	yield(get_tree().create_timer(2), "timeout")
	_reconnect()


func _on_connection_succeeded() -> void:
	print("connection to Authentication Server succeeded")

func _reconnect() -> void:
	print("attempting to reconnect to TokenTranfer")
	network.close_connection()
	_connect_to_token_transfer()

remote func receive_token(token: String, username: String) -> void:
	PlayerVerification.add_token(token, username)
