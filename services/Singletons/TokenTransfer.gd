extends Node

var network: NetworkedMultiplayerENet
var m_api: MultiplayerAPI
var ip = "127.0.0.1"
var port = 2010

var certificate = load("res://Resources/Certificates/cert_tokentransfer.crt")

func _process(delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_token_transfer():
	network = NetworkedMultiplayerENet.new()
	m_api = MultiplayerAPI.new()
	
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(certificate)
	
	network.create_client(ip, port)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_reconnect")

func _on_connection_failed() -> void:
	Logger.warning("connection to Authentication Server failed")
	yield(get_tree().create_timer(2), "timeout")
	_reconnect()


func _on_connection_succeeded() -> void:
	Logger.warning("connection to Authentication Server succeeded")

func _reconnect() -> void:
	Logger.warning("attempting to reconnect to TokenTranfer")
	network.close_connection()
	yield(get_tree().create_timer(2), "timeout")
	connect_to_token_transfer()

remote func receive_token(token: String, username: String) -> void:
	PlayerVerification.add_token(token, username)
