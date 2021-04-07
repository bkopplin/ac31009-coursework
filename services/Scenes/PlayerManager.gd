extends Node

var available_players: Dictionary # {username: client_id}

func player_connected(username: String, client_id: int):
	available_players[username] = client_id
	print("added player id " + str(client_id))
	print(available_players)
	Services.update_available_players()
	

func player_disconnected(player_id: int) -> void:
	print("player disconnected")
	print(available_players)
	var disconnected_player: String = ""
	for username in available_players:
		if available_players[username] == player_id:
			disconnected_player = username
	
	print(available_players)
	if disconnected_player != "":
		available_players.erase(disconnected_player)
		Services.update_available_players()

func get_available_users() -> Array:
	return available_players.keys()


func get_username(_player_id: int) -> String:
	for username in available_players.keys:
		if available_players[username] == _player_id:
			return username
	return ""
