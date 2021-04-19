extends Node

signal services_disconnected
signal return_verification_result
signal update_available_players
signal invitation_received
signal invitation_rejected
signal start_lobby
signal pre_configure_game
signal post_configure_game
signal receive_world_state
signal load_next_level
signal player_left_game

onready var playerList_screen: = get_node("/root/Main/Menu/PlayerList")
onready var lobby_screen: = get_node("/root/Main/Menu/Lobby")
onready var menu: = get_node("/root/Main/Menu")
onready var game_manager: = get_node("/root/Main/GameManager")

var network: NetworkedMultiplayerENet
var m_api: MultiplayerAPI
#var ip = "127.0.0.1"
var ip = "192.168.178.73"
var port = 2002

func _ready() -> void:
	self.connect("services_disconnected", playerList_screen, "_on_Services_services_disconnected")
	self.connect("return_verification_result", menu, "_on_Services_return_verification_result")
	self.connect("return_verification_result", playerList_screen, "_on_Services_return_verification_result")
	self.connect("update_available_players", playerList_screen, "update_available_players")
	self.connect("invitation_received", playerList_screen, "_on_Services_invitation_received")
	self.connect("invitation_rejected", playerList_screen, "_on_Services_invitation_rejected")
	self.connect("start_lobby", lobby_screen, "_on_Services_start_lobby")
	self.connect("start_lobby", menu, "_on_Services_start_lobby")
	self.connect("pre_configure_game", game_manager, "_on_pre_configure_game")
	self.connect("post_configure_game", game_manager, "_on_post_configure_game")
	self.connect("receive_world_state", game_manager, "_on_receive_world_state")
	self.connect("load_next_level", game_manager, "_on_load_next_level")
	self.connect("player_left_game", game_manager, "_on_player_left_game")
	
func _process(delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_services():
	print("connecting to services")
	network = NetworkedMultiplayerENet.new()
	m_api = MultiplayerAPI.new()

	network.create_client(ip, port)
	set_custom_multiplayer(m_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	Global.unique_game_id = custom_multiplayer.get_network_unique_id()
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_on_server_disconnected")

func _on_connection_failed():
	print("connection to Services failed")
	connect_to_services()

func _on_connection_succeeded() -> void:
	print("connection to Services succeeded, sending token and username")
	rpc_id(1, "verify", Global.token, Global.username)
	#rpc_id(1, "debug_game")

func _on_server_disconnected() -> void:
	print("Services Server disconnected, attempting to reconnect")
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
	print("calling Services.accept_invite")
	rpc_id(0, "accept_invitation", invitation)

remote func push_invite_rejected(invitation: Dictionary):
	emit_signal("invitation_rejected", invitation)

#################################
# Lobby
#################################

remote func start_lobby(lobby_state: Dictionary) -> void:
	print("start_lobby: " + str(lobby_state))
	emit_signal("start_lobby", lobby_state)

func ready_button_pressed(lobby_id: int, is_ready: bool) -> void:
	print("sending start game")
	rpc_id(0, "ready_button_pressed", lobby_id, is_ready)

func lobby_change_level(lobby_id: int, level_id: String) -> void:
	rpc_id(1, "lobby_change_level", lobby_id, level_id)

remote func lobby_update_selected_level(level_id: String) -> void:
	pass

##################################
# Game
##################################

remote func pre_configure_game(game_obj: Dictionary):
	print("pre_configuring_game")
	emit_signal("pre_configure_game", game_obj)

func done_preconfiguring(game_id: String):
	rpc_id(1, "done_preconfiguring", game_id)

remote func post_configure_game() -> void:
	print("received post configure game")
	emit_signal("post_configure_game")

func send_player_state(game_id: String, player_state: Dictionary) -> void:
	rpc_unreliable_id(1, "receive_player_state", game_id, player_state)

remote func receive_world_state(world_state) -> void:
	emit_signal("receive_world_state", world_state)

func level_finished() -> void:
	rpc_id(1, "level_finished", Global.game_id)

remote func load_next_level(level_name: String) -> void:
	emit_signal("load_next_level", level_name)

remote func player_left_game() -> void:
	emit_signal("player_left_game")
	
func leave_game() -> void:
	rpc_id(1, "leave_game")
####################################
# debug
####################################
