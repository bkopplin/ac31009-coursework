extends Node

signal players_ready

onready var game_manager = get_node("/root/Main/GameManager")

var lobbies: Dictionary

func _ready() -> void:
	self.connect("players_ready", game_manager, "start_game")

func start_lobby(invitation: Dictionary) -> void:
	Logger.debug("starting new lobby")
	# TODO: check if players have previously played together, otherwise create new lobby
	var lobby_id = gen_lobby_id()
	lobbies[lobby_id] = create_new_lobby(invitation, lobby_id)
	for player in lobbies[lobby_id].players:
		Services.start_lobby(player.id, lobbies[lobby_id])
	

func create_new_lobby(invitation: Dictionary, lobby_id: int) -> Dictionary:
	var lobby: Dictionary
	lobby.id = lobby_id
	lobby.players = [{"username": invitation.inviter, "id": invitation.inviter_id, "colour": Global.COLOUR_GREEN, "is_ready": false}, {"username": invitation.invitee, "id": invitation.invitee_id, "colour": Global.COLOUR_BLUE, "is_ready": false}]
	lobby.selected_level = "1"
	return lobby

func gen_lobby_id() -> int:
	randomize()
	var n: int = randi() * 8
	while lobbies.has(n):
		n = randi() * 8
	return n

func ready_button_pressed(lobby_id: int, is_ready: bool, client_id: int) -> void:
	var all_ready: = true
	for player in lobbies[lobby_id].players:
		if player.id == client_id:
			player.is_ready = is_ready
		all_ready = all_ready and player.is_ready
	if all_ready:
		lobbies[lobby_id].levels = Global.levels.duplicate(true)
		emit_signal("players_ready", lobbies[lobby_id])

func change_level(client_id: int, lobby_id: int, level_id: String):
	if not Global.levels.keys().has(level_id):
		print("level id not in available levels")
		return
	lobbies[lobby_id].selected_level = level_id
	for player in lobbies[lobby_id].players:
		if player.id == client_id:
			continue
		Services.lobby_update_selected_level(player.id, level_id)
	
