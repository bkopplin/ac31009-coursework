extends Node

var network = NetworkedMultiplayerENet.new()
var m_api = MultiplayerAPI.new()
var port = 2003
var maxplayers = 5
onready var tree: SceneTree = get_tree()

var connected_services: Array

func _ready() -> void:
	start_tokentransfer()

func _process(delta) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func start_tokentransfer() -> void:
	network.create_server(port, maxplayers)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	print("TokenTransfer listening on port " + str(port))
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")

func _on_peer_connected(client_id) -> void:
	print(str(client_id) + " connected to TokenTransfer")
	connected_services.append(client_id)

func _on_peer_disconnected(client_id) -> void:
	print (str(client_id) + " disconnected to TokenTranfer")
	connected_services.remove(client_id)

func send_token(token, username) -> void:
	var service = get_best_service()
	if service >= 0:
		rpc_id(service, "receive_token", token, username)
	else:
		print("Error: no Service server connected to TokenTransfer")

func get_best_service() -> int:
	# TODO implement load-balancing for services and redirect players to appropriate Server
	if connected_services.size() > 0:
		return connected_services[0]
	return -1
