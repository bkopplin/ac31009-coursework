extends Node

signal return_verification_result
signal update_available_players
signal invitation_received
signal invitation_rejected

onready var playerList_screen: = get_node("/root/Menu/PlayerList")
onready var lobby_screen: = get_node("/root/Menu/Lobby")
onready var menu: = get_node("/root/Menu")

var network: NetworkedMultiplayerENet
var m_api: MultiplayerAPI
var ip = "127.0.0.1"
var port = 2002

func _ready() -> void:
	self.connect("return_verification_result", menu, "_on_Services_return_verification_result")
	self.connect("update_available_players", playerList_screen, "_on_Services_update_available_players")
	self.connect("invitation_received", playerList_screen, "_on_Services_invitation_received")
	self.connect("invitation_rejected", playerList_screen, "_on_Services_invitation_rejected")
	
func _process(delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_services():
	network = NetworkedMultiplayerENet.new()
	m_api = MultiplayerAPI.new()

	network.create_client(ip, port)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed():
	print("connection to Services failed")

func _on_connection_succeeded() -> void:
	print("connection to Services succeeded, sending token and username")
	rpc_id(1, "verify", Global.token, Global.username)


func disconnect_from_services() -> void:
	if network.is_connected("connection_failed", self, "_on_connection_failed"):
		network.disconnect("connection_failed", self, "_on_connection_failed")
	if network.is_connected("connection_succeeded", self, "_on_connection_succeeded"):
		network.disconnect("connection_succeeded", self, "_on_connection_succeeded")

#############################
# Verification
#############################

remote func return_verification_result(result) -> void:
	print("return_verification_result")
	emit_signal("return_verification_result", result)

#############################
# update player list
#############################

func fetch_available_players() -> void:
	print("fetch available players")
	rpc_id(1, "fetch_available_players")


remote func update_available_players(players: Array) -> void:
	print("Services: update_available_players: received players: " + str(players))
	emit_signal("update_available_players", players)

###############################
# invitations
###############################

func invite(username: String) -> void:
	rpc_id(0, "invite", Global.username, username)

remote func push_invite(invitation: Dictionary) -> void:
	print("Services: push_invite: invitation received")
	emit_signal("invitation_received", invitation)

func reject_invitation(invitation: Dictionary) -> void:
	rpc_id(0, "reject_invite", invitation)

func accept_invitation(invitation: Dictionary) -> void:
	rpc_id(0, "accept_invite", invitation)

remote func push_invite_rejected(invitation: Dictionary):
	emit_signal("invitation_rejected", invitation)


