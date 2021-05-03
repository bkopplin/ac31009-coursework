extends Node

signal player_requests_verification
signal player_disconnected
# Invitations
signal invite_send
signal invite_accepted
signal invite_rejected
signal invite_cancelled
# Game
signal done_preconfiguring
signal receive_player_state
signal exit_area_entered
signal exit_area_left
signal player_left_game

onready var main: = get_node("/root/Main")
onready var game_manager: = get_node("/root/Main/GameManager")
onready var tree: SceneTree = get_tree()

var network = NetworkedMultiplayerENet.new()
var m_api = MultiplayerAPI.new()
var port = 2001
var maxplayers = 200


func _ready() -> void:
	self.connect("player_requests_verification", main, "_on_player_requests_verification")
	self.connect("player_disconnected", main, "_on_player_disconnected")
	# Invitations
	self.connect("invite_accepted", main, "_on_invite_accepted")
	self.connect("invite_send", main, "_on_invite_send")
	self.connect("invite_cancelled", main, "_on_invite_cancelled")
	self.connect("invite_rejected", main, "_on_invite_rejected")
	# GameManager
	self.connect("done_preconfiguring", game_manager, "_on_done_preconfiguring")
	self.connect("receive_player_state", game_manager, "_on_receive_player_state")
	self.connect("exit_area_entered", game_manager, "_on_exit_area_entered")
	self.connect("exit_area_left", game_manager, "_on_exit_area_left")
	self.connect("player_left_game", main, "_on_player_left_game")

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
	
	Logger.info("Services listening on port " + str(port))
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")

func _on_peer_connected(_client_id) -> void:
	var client_id = _client_id
	Logger.info(str(client_id) + " connected")


func _on_peer_disconnected(client_id) -> void:
	emit_signal("player_disconnected", client_id)

#############################
# Verification
#############################

remote func verify(token: String, username: String) -> void:
	var client_id = custom_multiplayer.get_rpc_sender_id()
	emit_signal("player_requests_verification", client_id, token, username)

func return_verification_result(client_id: int, result) -> void:
	rpc_id(client_id, "return_verification_result", result)
	
#############################
# update player list
#############################

func update_waitingroom(client_id: int, players: Array) -> void:
	rpc_id(client_id, "update_available_players", players)

#############################
# Invitations
#############################

remote func invite_send(invitee: String) -> void:
	var client_id = custom_multiplayer.get_rpc_sender_id()
	emit_signal("invite_send", client_id, invitee)

remote func invite_accepted(invitation: Dictionary) -> void:
	emit_signal("invite_accepted", invitation)

remote func invite_rejected(invitation: Dictionary) -> void:
	emit_signal("invite_rejected", invitation)

remote func invite_cancelled() -> void:
	var client_id = custom_multiplayer.get_rpc_sender_id()
	emit_signal("invite_cancelled", client_id)


func send_invite(client_id: int, invitation: Dictionary) -> void:
	rpc_id(client_id, "receive_invite", invitation)

func send_invite_rejected(client_id: int, invitation: Dictionary) -> void:
	rpc_id(client_id, "receive_invite_rejected", invitation)

func send_invite_cancelled(client_id: int, invitation: Dictionary) -> void:
	Logger.debug("Services: send_invite_cancelled to " + str(client_id))
	rpc_id(client_id, "receive_invite_cancelled", invitation)

func send_invite_error(client_id: int, message: String) -> void:
	rpc_id(client_id, "receive_invite_error", message)

######################################
# Game
######################################

func pre_configure_game(client_id: int, game_obj: Dictionary) -> void:
	print("sending pre_configure_game to " + str(client_id))
	rpc_id(client_id, "pre_configure_game", game_obj)

remote func done_preconfiguring(game_id: String):
	var client_id = custom_multiplayer.get_rpc_sender_id()
	game_manager._on_done_preconfiguring(client_id, game_id)

func post_configure_game(client_id: int) -> void:
	print("sending post configure game to : " + str(client_id))
	rpc_id(client_id, "post_configure_game")

remote func receive_player_state(game_id: String, player_state) -> void:
	var client_id = custom_multiplayer.get_rpc_sender_id()
	emit_signal("receive_player_state", game_id, client_id, player_state)

func send_world_state(client_id: int, world_state) -> void:
	rpc_unreliable_id(client_id, "receive_world_state", world_state)

remote func exit_area_entered(game_id: String) -> void:
	var client_id: = custom_multiplayer.get_rpc_sender_id()
	emit_signal("exit_area_entered", game_id, client_id)

remote func exit_area_left(game_id: String) -> void:
	var client_id: = custom_multiplayer.get_rpc_sender_id()
	emit_signal("exit_area_left", game_id, client_id)

func load_next_level(client_id: int, level_name: String) -> void:
	rpc_id(client_id, "load_next_level", level_name)

remote func leave_game() -> void:
	var client_id = custom_multiplayer.get_rpc_sender_id()
	emit_signal("player_left_game", client_id)

func player_left_game(client_id: int) -> void:
	rpc_id(client_id, "player_left_game")

