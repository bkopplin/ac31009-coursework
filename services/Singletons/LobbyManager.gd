extends Node

signal start_game
onready var game_manager = get_node("/root/Main/GameManager")
var lobbies: Dictionary

func _ready() -> void:
	self.connect("start_game", game_manager, "start_game")

func start_lobby(invitation: Dictionary) -> void:
	print("starting new lobby")
	# TODO: check if players have previously played together, otherwise create new lobby
	var lobby_id = gen_lobby_id()
	lobbies[lobby_id] = create_new_lobby(invitation, lobby_id)
	for player in lobbies[lobby_id].players:
		Services.start_lobby(player.id, lobbies[lobby_id])
	

func create_new_lobby(invitation: Dictionary, lobby_id: int) -> Dictionary:
	var lobby: Dictionary
	lobby.id = lobby_id
	lobby.players = [{"username": invitation.inviter, "id": invitation.inviter_id, "colour": "green", "is_ready": false}, {"username": invitation.invitee, "id": invitation.invitee_id, "colour": "blue", "is_ready": false}]
	lobby.selected_level = "1"
	lobby.levels = [
		{"id": "1", "name": "Beginner level", "completed": true, "next_level": "1"}, 
		{"id": "2", "name": "Second Level", "completed": false, "next_level": "2"},
		{"id": "3", "name": "Through the canyon", "completed": false, "next_level": "3"},]
	return lobby

func gen_lobby_id() -> int:
	randomize()
	var n: int = randi() * 8
	while lobbies.has(n):
		n = randi() * 8
	return n

func start_game(lobby_id: int, is_ready: bool, client_id: int) -> void:
	var all_ready: = true
	for player in lobbies[lobby_id].players:
		if player.id == client_id:
			player.is_ready = is_ready
		all_ready = all_ready and player.is_ready
	if all_ready:
		print("all ready, starting game")
		emit_signal("start_game", lobbies[lobby_id])
