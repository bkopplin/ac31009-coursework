extends Node

signal done_preconfiguring
signal receive_player_state
signal exit_area_entered
signal exit_area_left
signal player_left_game

onready var game_manager = get_node("/root/Main/GameManager")

var network = NetworkedMultiplayerENet.new()
var m_api = MultiplayerAPI.new()
var port = 2001
var maxplayers = 200
onready var tree: SceneTree = get_tree()

func _ready() -> void:
	self.connect("done_preconfiguring", game_manager, "_on_done_preconfiguring")
	self.connect("receive_player_state", game_manager, "_on_receive_player_state")
	self.connect("exit_area_entered", game_manager, "_on_exit_area_entered")
	self.connect("exit_area_left", game_manager, "_on_exit_area_left")
	self.connect("player_left_game", game_manager, "_on_player_left_game")

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
	Logger.info(str(client_id) + " disconnected")
	PlayerManager.player_left_game(client_id)
	emit_signal("player_left_game", client_id)


#############################
# Verification
#############################

remote func verify(token: String, username: String) -> void:
	var player_id = custom_multiplayer.get_rpc_sender_id()
	print("Services: verify: username=" + username + ", token=" + token)
	var verified = PlayerVerification.verify(token, username)
	print(verified)
	if verified:
		print(username + " verified.")
		PlayerManager.player_connected(username, player_id)
	
	print("verify: player_id: " + str(player_id))
	rpc_id(player_id, "return_verification_result", verified)

#############################
# update player list
#############################

func update_waitingroom(client_id: int, players: Array) -> void:
	rpc_id(client_id, "update_available_players", players)

# deprecated
#func update_available_players() -> void:
#	var p = PlayerManager.get_available_users()
#	rpc_id(0, "update_available_players", p)

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
	# DEBUG SETTING
	# uncomment to use lobby
#	PlayerManager.remove_invitation(invitation)
	#LobbyManager.start_lobby(invitation)
	
	var l = LobbyManager.create_new_lobby(invitation, LobbyManager.gen_lobby_id())
	game_manager.start_game(l)

remote func accept_invite(invitation: Dictionary) -> void:
	print("invitation accepted: " + str(invitation))
	PlayerManager.remove_invitation(invitation)
	LobbyManager.start_lobby(invitation)

#####################################
# Lobby
#####################################

func start_lobby(client_id: int, lobby_state: Dictionary) -> void:
	Logger.debug("sending start lobby to " + str(client_id))
	rpc_id(client_id, "start_lobby", lobby_state)

remote func ready_button_pressed(lobby_id: int, is_ready: bool) -> void:
	var client_id = custom_multiplayer.get_rpc_sender_id()
	LobbyManager.ready_button_pressed(lobby_id, is_ready, client_id)

remote func lobby_change_level(lobby_id: int, level_id: String) -> void:
	var client_id = custom_multiplayer.get_rpc_sender_id()
	LobbyManager.change_level(client_id, lobby_id, level_id)

func lobby_update_selected_level(client_id:int, level_id: String) -> void:
	rpc_id(client_id, "lobby_update_selected_level", level_id)
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
#########################################
# debug
#########################################

remote func debug_game() -> void:
	var client_id = custom_multiplayer.get_rpc_sender_id()
	print(PlayerManager.available_players.keys().size())
	if PlayerManager.available_players.keys().size() == 1:
		print("second client connected to debug_game, starting game")
		PlayerManager.player_connected("Player2", client_id)
		var temp: Dictionary
		temp.players = [{"username": "player1", "id": PlayerManager.available_players["Player1"], "colour": "green"}, {"username": "player2", "id": client_id, "colour": "blue"}]
		temp.selected_level = "1"
		get_node("/root/Main/GameManager").start_game(temp)
	else:
		print("first client connected to debug_game")
		PlayerManager.player_connected("Player1", client_id)
