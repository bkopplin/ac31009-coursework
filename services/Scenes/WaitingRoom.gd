extends Node
class_name Waitingroom

var waitingroom: Dictionary

func update_waitingroom() -> void:
	"""
	Makes an rpc call to all connected clients to send them the newest version
	of the waiting room
	"""
	var usernames = waitingroom.keys()
	for client_id in waitingroom.values():
		Services.update_waitingroom(client_id, usernames)

func add(client_id: int, username: String) -> void:
	waitingroom[username] = client_id
	update_waitingroom()

func remove_client(client_id: int) -> bool:
	"""
	Removes a player from the waitingroom
	returns true if the player was in the waiting room
	"""
	var to_remove: = ""
	for username in waitingroom:
		if waitingroom[username] == client_id:
			to_remove = username
			break
	if to_remove != "":
		waitingroom.erase(to_remove)
		update_waitingroom()
		return true
	else:
		return false

