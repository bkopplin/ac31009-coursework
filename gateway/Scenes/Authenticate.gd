extends Node

var network = NetworkedMultiplayerENet.new()
var port = 2001
var ip = "127.0.0.1"

func _ready() -> void:
	connect_to_authserver()

func connect_to_authserver() -> void:
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	print("attempting connection to Authentication Server")
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_reconnect")

func _on_connection_failed() -> void:
	print("Failed to connect to authentication server")
	_reconnect()

func _on_connection_succeeded() -> void:
	print("Successfully connected to authentication server")


func _reconnect() -> void:	
	network.close_connection()
	connect_to_authserver()

##############################
# Login 
##############################

func login_request(username: String, password: String, player_id: int) -> void:
	rpc_id(1, "login_request", username, password, player_id)

remote func return_login_results(token: String, result: bool, player_id: int) -> void:
	print("received auth token " + str(token))
	Gateway.return_login_results(token, result, player_id)

##############################
# Signup
##############################

func signup_request(options: Dictionary, player_id: int) -> void:
	print("send signup request to auth server")
	rpc_id(1, "signup_request", options, player_id)

remote func return_signup_results(token: String, result: bool, player_id: int) -> void:
	print("received signup results")
	Gateway.return_signup_results(token, result, player_id)


func _on_ConnectionTimer_timeout() -> void:
	connect_to_authserver()
