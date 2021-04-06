extends Node

var network: NetworkedMultiplayerENet
var m_api: MultiplayerAPI
var ip = "127.0.0.1"
var port = 2000

# var certificate = load("")

func _process(delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func _create_network_api():
	network = NetworkedMultiplayerENet.new()
	m_api = MultiplayerAPI.new()
#	network.set_dtls_enabled(true)
#	network.set_dtls_verify_enabled(false)
#	network.set_dtls_certificate(certificate)
	network.create_client(ip, port)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed():
	print("connection to gatewayserver failed")

func _on_connection_succeeded():
	pass

func login_request(username, password):
	_create_network_api()
	rpc_id(1, "login_request", username, password)


func create_account(username, password):
	_create_network_api()

remote func return_login_results(token, error):
	# if login request returns true, connect to server
	network.disconnect("connection_failed", self, "_on_connection_failed")
	network.disconnect("connection_succeeded", self, "_on_connection_succeeded")
