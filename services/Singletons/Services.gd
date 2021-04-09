extends Node

signal done_preconfiguring
onready var game_manager = get_node("/root/Main/GameManager")

var network = NetworkedMultiplayerENet.new()
var m_api = MultiplayerAPI.new()
var port = 2002
var maxplayers = 200
onready var tree: SceneTree = get_tree()

func _ready() -> void:
	start_services()
	self.connect("done_preconfiguring", game_manager, "_on_done_preconfiguring")

func _process(delta) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func start_services() -> void:
	network.create_server(port, maxplayers)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	print("Services listening on port " + str(port))
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")

func _on_peer_connected(client_id) -> void:
	print(str(client_id) + " connected")

func _on_peer_disconnected(client_id) -> void:
	print (str(client_id) + " disconnected")
	PlayerManager.player_disconnected(client_id)

#############################
# Verification
#############################

remote func verify(token: String, username: String) -> void:
	var player_id = custom_multiplayer.get_rpc_sender_id()
#	print("received token=" + token + ", username=" + username)
	var verified = PlayerVerification.verify(token, username)
	if verified:
		print(username + " verified.")
		print("in verify player id: " + str(player_id))
		PlayerManager.player_connected(username, player_id)
	rpc_id(player_id, "return_verification_result", verified)

#############################
# update player list
#############################

func update_available_players() -> void:
	var p = PlayerManager.get_available_users()
	rpc_id(0, "update_available_players", p)

remote func fetch_available_players() -> void:
	print("fetch_available_players")
	var client_id = custom_multiplayer.get_rpc_sender_id()
	var p = PlayerManager.get_available_users()
	rpc_id(client_id, "update_available_players", p)

#############################
# Invitations
#############################

remote func invite(inviter: String, invitee: String) -> void:
	print("received invite")
	var inviter_id = custom_multiplayer.get_rpc_sender_id()
	PlayerManager.invite(inviter, invitee, inviter_id)

func send_invitation(invitation: Dictionary) -> void:
	print("sending out invitation")
	var client_id = invitation.invitee_id
	rpc_id(client_id, "push_invite", invitation)

func send_reject_invite(invitation: Dictionary):
	print("Services: send_reject_invite")
	var client_id = invitation.inviter_id
	rpc_id(client_id, "push_invite_rejected", invitation)

remote func reject_invite(invitation: Dictionary) -> void:
	send_reject_invite(invitation)

remote func accept_invitation(invitation: Dictionary) -> void:
	print("invitation accepted")
#	PlayerManager.remove_invitation(invitation)
	LobbyManager.start_lobby(invitation)

remote func accept_invite(invitation: Dictionary) -> void:
	print("invitation accepted: " + str(invitation))
	PlayerManager.remove_invitation(invitation)
	LobbyManager.start_lobby(invitation)

func start_lobby(client_id: int, lobby_state: Dictionary) -> void:
	print("sending start lobby to " + str(client_id))
	rpc_id(client_id, "start_lobby", lobby_state)

remote func ready_button_pressed(lobby_id: int, is_ready: bool) -> void:
	var client_id = custom_multiplayer.get_rpc_sender_id()
	LobbyManager.start_game(lobby_id, is_ready, client_id)

######################################
# Game
######################################

func pre_configure_game(client_id: int, level: PackedScene) -> void:
	print("sending pre_configure_game to " + str(client_id))
	print(level)
	rpc_id(client_id, "pre_configure_game", level)

remote func done_preconfiguring():
	var client_id = custom_multiplayer.get_rpc_sender_id()
	
