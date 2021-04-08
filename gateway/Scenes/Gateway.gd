extends Node

var network = NetworkedMultiplayerENet.new()
var m_api = MultiplayerAPI.new()
var port = 2000
var maxplayers = 80
onready var tree: SceneTree = get_tree()
#var certificate = load("res://certificate/x509_certificate.crt")
#var key = load("res://certificate/x509_key.key")

func _ready() -> void:
	start_gateway()

func _process(delta) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func start_gateway() -> void:
	#network.set_dtls_enabled(true)
	#network.set_dtls_key(key)
	#network.set_dtls_certificate(certificate)
	network.create_server(port, maxplayers)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	print("gateway listening on port " + str(port))
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")

func _on_peer_connected(player_id) -> void:
	print(str(player_id) + " connected")

func _on_peer_disconnected(player_id) -> void:
	print (str(player_id) + " disconnected")


remote func login_request(username: String, password: String) -> void:
	var client_id = tree.get_rpc_sender_id()
	Authenticate.login_request(username, password, client_id)

func return_login_results(token: String, result: bool, player_id: int) -> void:
	rpc_id(player_id, "return_login_results", token, result)
	network.disconnect_peer(player_id)


remote func signup_request(params: Dictionary) -> void:
	var client_id = tree.get_rpc_sender_id()
	print("received signup request")
	Authenticate.signup_request(params, client_id)

func return_signup_results(token: String, result: bool, player_id: int) -> void:
	print("returning singup results")
	rpc_id(player_id, "return_signup_results", token, result)
	network.disconnect_peer(player_id)
