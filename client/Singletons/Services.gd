extends Node

signal services_disconnected
signal return_verification_result
signal update_available_players
signal invitation_received
signal invitation_rejected
signal pre_configure_game
signal post_configure_game
signal receive_world_state
signal load_next_level
signal player_left_game
signal invitation_cancelled

onready var playerList_screen: = get_node("/root/Main/Menu/PlayerList")
onready var menu: = get_node("/root/Main/Menu")
onready var game_manager: = get_node("/root/Main/GameManager")

var network: NetworkedMultiplayerENet
var m_api: MultiplayerAPI


func _ready() -> void:
	self.connect("services_disconnected", playerList_screen, "_on_Services_services_disconnected")
	self.connect("return_verification_result", menu, "_on_Services_return_verification_result")
	self.connect("return_verification_result", playerList_screen, "_on_Services_return_verification_result")
	self.connect("update_available_players", playerList_screen, "update_available_players")
	self.connect("invitation_received", playerList_screen, "_on_Services_invitation_received")
	self.connect("invitation_rejected", playerList_screen, "_on_Services_invitation_rejected")
	self.connect("start_lobby", menu, "_on_Services_start_lobby")
	self.connect("pre_configure_game", game_manager, "_on_pre_configure_game")
	self.connect("post_configure_game", game_manager, "_on_post_configure_game")
	self.connect("receive_world_state", game_manager, "_on_receive_world_state")
	self.connect("load_next_level", game_manager, "_on_load_next_level")
	self.connect("player_left_game", game_manager, "_on_player_left_game")
	self.connect("invitation_cancelled", playerList_screen, "_on_invitation_cancelled")
	
func _process(delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_services():
	network = NetworkedMultiplayerENet.new()
	m_api = MultiplayerAPI.new()

	network.create_client(Global.services_ip, Global.services_port)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	Global.unique_game_id = custom_multiplayer.get_network_unique_id()
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_on_server_disconnected")

func _on_connection_failed():
	yield(get_tree().create_timer(2), "timeout")
	connect_to_services()

func _on_connection_succeeded() -> void:
	get_verification()
	#rpc_id(1, "debug_game")

func _on_server_disconnected() -> void:
	emit_signal("services_disconnected")
	connect_to_services()
	

func disconnect_from_services() -> void:
	if network.is_connected("connection_failed", self, "_on_connection_failed"):
		network.disconnect("connection_failed", self, "_on_connection_failed")
	if network.is_connected("connection_succeeded", self, "_on_connection_succeeded"):
		network.disconnect("connection_succeeded", self, "_on_connection_succeeded")

#############################
# Verification
#############################

remote func get_verification() -> void:
	rpc_id(1, "verify", Global.token, Global.username)

remote func return_verification_result(result) -> void:
	emit_signal("return_verification_result", result)

#############################
# update player list
#############################

remote func update_available_players(players: Array) -> void:
	emit_signal("update_available_players", players)

###############################
# invitations
###############################

remote func receive_invite(invitation: Dictionary) -> void:
	emit_signal("invitation_received", invitation)

remote func receive_invite_cancelled(invitation: Dictionary) -> void:
	emit_signal("invitation_cancelled", invitation)

remote func receive_invite_rejected(invitation: Dictionary) -> void:
	emit_signal("invitation_rejected", invitation)

remote func receive_invite_error(message: String) -> void:
	print("Services: receive_invite_error: " + message)

func send_invite(invitee: String) -> void:
	rpc_id(0, "invite_send", invitee)

func accept_invite(invitation: Dictionary) -> void:
	rpc_id(0, "invite_accepted", invitation)

func reject_invite(invitation: Dictionary) -> void:
	rpc_id(0, "invite_rejected", invitation)

func cancel_invite() -> void:
	rpc_id(0, "invite_cancelled")

#####

func invite(username: String) -> void:
	rpc_id(0, "invite", Global.username, username)

remote func push_invite(invitation: Dictionary) -> void:
	emit_signal("invitation_received", invitation)

func reject_invitation(invitation: Dictionary) -> void:
	rpc_id(0, "reject_invite", invitation)

func accept_invitation(invitation: Dictionary) -> void:
	rpc_id(0, "accept_invitation", invitation)

remote func push_invite_rejected(invitation: Dictionary):
	emit_signal("invitation_rejected", invitation)

func cancel_invitation() -> void:
	rpc_id(0, "cancel_invitation")

##################################
# Game
##################################

remote func pre_configure_game(game_obj: Dictionary):
	emit_signal("pre_configure_game", game_obj)

func done_preconfiguring(game_id: String):
	rpc_id(1, "done_preconfiguring", game_id)

remote func post_configure_game() -> void:
	emit_signal("post_configure_game")

func send_player_state(game_id: String, player_state: Dictionary) -> void:
	rpc_unreliable_id(1, "receive_player_state", game_id, player_state)

remote func receive_world_state(world_state) -> void:
	emit_signal("receive_world_state", world_state)

func exit_area_entered() -> void:
	rpc_id(1, "exit_area_entered", Global.game_id)

func exit_area_left() -> void:
	rpc_id(1, "exit_area_left", Global.game_id)

remote func load_next_level(level_name: String) -> void:
	emit_signal("load_next_level", level_name)

remote func player_left_game() -> void:
	emit_signal("player_left_game")
	
func leave_game() -> void:
	rpc_id(1, "leave_game")

