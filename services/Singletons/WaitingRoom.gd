extends Node

var players: Dictionary 
var usernames: Dictionary

func add_player(client_id: int, username: String) -> void:
	if not players.has(client_id):
		players[client_id] = username
		usernames[username] = client_id

func remove_player(client_id: int) -> void:
	players.erase(client_id)


