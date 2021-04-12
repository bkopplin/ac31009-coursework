extends Node

var available_players: Dictionary # {username: client_id}
var invitations: Dictionary # {sender: {timestamp, receiver}}

func player_connected(username: String, client_id: int):
	available_players[username] = client_id
	print("added player to available players: " + str(client_id))
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

func invite(_inviter: String, _invitee: String, _inviter_id: int) -> void:
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
	print("invitation removed")
