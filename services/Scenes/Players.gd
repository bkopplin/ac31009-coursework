extends Node
class_name Players
"""
A Node that stores the client_id and username of connected clients
and provides functionalities to manipulate these entries
"""

var players: Dictionary
var clients: Dictionary

func add(client_id: int, username: String) -> void:
	clients[client_id] = username
	players[username] = client_id

func is_client_connected(client_id: int) -> bool:
	return true if clients.has(client_id) else false

func is_player_connected(username: String) -> bool:
	return true if players.has(username) else false

func remove_client(client_id: int) -> void:
	players.erase(get_username(client_id))
	clients.erase(client_id)

func remove_player(username: String) -> void:
	clients.erase(get_client_id(username))
	players.erase(username)

func get_username(client_id: int) -> String:
	return clients[client_id]

func get_client_id(username: String) -> int:
	return players[username] if players.has(username) else -1
	
