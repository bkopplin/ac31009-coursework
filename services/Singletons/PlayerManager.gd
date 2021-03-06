extends Node

var available_players: Dictionary # {username: client_id}
var invitations: Dictionary # {sender: {timestamp, receiver}}

func player_connected(username: String, client_id: int):
	add_to_waitingroom(username, client_id)
	update_waitingroom()
	

func player_left_game(player_id: int) -> void:
	Logger.info("player " + str(player_id) + " disconnected")
	if remove_from_waitingroom(player_id):
		update_waitingroom()

	
func is_in_waitingroom(player_id: int) -> bool:
	if available_players.values().has(player_id):
		return true
	return false

func update_waitingroom() -> void:
	"""
	Makes an rpc call to all connected clients to send them the newest version
	of the waiting room
	"""
	var players = available_players.keys()
	for client_id in available_players.values():
		Services.update_waitingroom(client_id, players)

func add_to_waitingroom(username: String, client_id: int) -> void:
	available_players[username] = client_id

func remove_from_waitingroom(player_id: int) -> bool:
	"""
	Removes a player from the waitingroom
	returns true if the player was in the waiting room
	"""
	var to_remove: = ""
	for username in available_players:
		if available_players[username] == player_id:
			to_remove = username
			break
	if to_remove != "":
		available_players.erase(to_remove)
		return true
	else:
		return false

func get_available_users() -> Array:
	return available_players.keys()

func invite(_inviter: String, _invitee: String, _inviter_id: int) -> void:
	if not available_players.has(_invitee):
		Logger.debug("debug: player " + str(_invitee) + " is not available")
		return
	var invitation: Dictionary
	invitation.inviter = _inviter
	invitation.invitee = _invitee
	invitation.inviter_id = _inviter_id
	invitation.invitee_id = available_players[_invitee]
	invitation.message = ""
	invitation.timestamp = OS.get_system_time_secs()
	
	if invitation.inviter == invitation.invitee:
		invitation.message = "you cannot invite yourself"
		Services.send_reject_invite(invitation)
		return
		
	if invitation.invitee_id <= 0:
		invitation.message = str(invitation.invitee) + " is not available on server"
		Services.send_reject_invite(invitation)
		return
	
	var invitation_id = gen_invitation_id(invitation.inviter, invitation.invitee)
	invitations[invitation_id] = invitation
	Services.send_invitation(invitation)

func gen_invitation_id(inviter: String, invitee: String) -> String:
	return str(inviter) + "+" + str(invitee)

func remove_invitation(invitation: Dictionary) -> void:
	var invitation_id = gen_invitation_id(invitation.inviter, invitation.invitee)
	invitations.erase(invitation_id)
	Logger.debug("invitation removed")
