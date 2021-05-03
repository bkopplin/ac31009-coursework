extends Node

signal login_result_received
signal signup_result_received

onready var login_screen = get_node("/root/Main/Menu/LoginScreen")
onready var signup_screen = get_node("/root/Main/Menu/SignupScreen")

var network: NetworkedMultiplayerENet
var m_api: MultiplayerAPI

onready var menu: Node = get_node("/root/Main/Menu")
var certificate = load("res://Resources/Certificates/cert_gateway.crt")

func _ready() -> void:
	self.connect("login_result_received", login_screen, "_on_login_result_received")
	self.connect("signup_result_received", signup_screen, "_on_signup_result_received")

func _process(delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func _connect_to_gateway(callback: String, binds):
	print("Gateway: connecting to gateway")
	network = NetworkedMultiplayerENet.new()
	m_api = MultiplayerAPI.new()
	
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(certificate)

	network.create_client(Global.gateway_ip, Global.gateway_port)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded", [callback, binds])
	network.connect("server_disconnected", self, "_disconnect_from_gateway")

func _on_connection_failed():
	print("connection to gateway failed")

func _on_connection_succeeded(callback: String, binds) -> void:
	call(callback, binds)
	print("connection to gateway succeeded")

func _disconnect_from_gateway() -> void:
	if network.is_connected("connection_failed", self, "_on_connection_failed"):
		network.disconnect("connection_failed", self, "_on_connection_failed")
	if network.is_connected("connection_succeeded", self, "_on_connection_succeeded"):
		network.disconnect("connection_succeeded", self, "_on_connection_succeeded")

func login_request(username: String, password: String) -> void:
	_connect_to_gateway("send_login_request", [username, password])

func send_login_request(params: Array) -> void:
	rpc_id(1, "login_request", params[0], params[1])
	
remote func return_login_results(token: String, result: bool):
	emit_signal("login_result_received", token, result)
	_disconnect_from_gateway()


func signup_request(params: Dictionary) -> void:
	_connect_to_gateway("send_signup_request", params)
	
func send_signup_request(params: Dictionary) -> void:
	rpc_id(1, "signup_request", params)
	
remote func return_signup_results(token: String, result: bool) -> void:
	emit_signal("signup_result_received", token, result)
	_disconnect_from_gateway()
