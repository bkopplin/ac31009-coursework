extends Node

var network = NetworkedMultiplayerENet.new()
var m_api = MultiplayerAPI.new()
var port = 2000
var maxplayers = 80

# TODO change filenames
var certificate = load("res://certificate/x509_certificate.crt")
var key = load("res://certificate/x509_key.key")

func _ready() -> void:
	start_gateway()


func _process(delta) -> void:
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func start_gateway() -> void:
	network.set_dtls_enabled(true)
	network.set_dtls_key(key)
	network.set_dtls_certificate(certificate)
	network.create_server(port, maxplayers)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")

func _on_peer_connected(player_id) -> void:
	print(player_id + " connected")

func _on_peer_disconnected(player_id) -> void:
	print (player_id + " disconnected")


remote func login_request(username: String, password: String) -> void:
	var player_id = network.get_rpc_sender_id()
	Authenticate.login_request(username, password, player_id)
	
func return_login_results(token: String, error: String, player_id: int):
	rpc_id(player_id, "return_login_results", token, error)
