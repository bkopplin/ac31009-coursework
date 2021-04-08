extends Node

var lobbies: Dictionary

func start_lobby(invitation: Dictionary) -> void:
	print("starting new lobby")
	# TODO: check if players have previously played together, otherwise create new lobby
	var lobby_id = gen_lobby_id()
	lobbies[lobby_id] = create_new_lobby(invitation)
	for player in lobbies[lobby_id].players:
		Services.start_lobby(player.id, lobbies[lobby_id])
	

func create_new_lobby(invitation: Dictionary) -> Dictionary:
	var lobby: Dictionary
	lobby.players = [{"username": invitation.inviter, "id": invitation.inviter_id, "colour": "red"}, {"username": invitation.invitee, "id": invitation.invitee_id, "colour": "green"}]
	lobby.selected_level = "0"
	lobby.completed_levels = []
	return lobby

func gen_lobby_id() -> int:
	randomize()
	var n: int = randi() * 8
	while lobbies.has(n):
		n = randi() * 8
	return n

func test() -> void:
	print("test")
