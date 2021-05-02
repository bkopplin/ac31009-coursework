extends Node

onready var players: = get_node("Players")
onready var waitingroom: = get_node("WaitingRoom")
onready var invitations: = get_node("Invitations")
onready var game_manager: = get_node("GameManager")

func _ready() -> void:
	Logger.level = 4
	Services.start_services()
	TokenTransfer.connect_to_token_transfer()

func _on_player_requests_verification(client_id: int, token: String, username: String) -> void:
	var verified = not players.is_player_connected(username) and PlayerVerification.verify(token, username)
	if verified:
		players.add(client_id, username)
		waitingroom.add(client_id, username)
	Services.return_verification_result(client_id, verified)

func _on_player_disconnected(client_id: int) -> void:
	Logger.info(str(client_id) + " disconnected")
	if waitingroom.remove_client(client_id):
		players.remove_client(client_id)
		cancel_invite(client_id)
	elif game_manager.is_player_in_game(client_id):
		game_left_by(client_id)
		players.remove_client(client_id)
	
		
	# TODO: reject the invite of someone who was invited
	

func _on_invite_send(client_id: int, invitee: String):
	Logger.debug("Main: _on_invite_send")
	if invitee == "":
		Services.send_invite_error(client_id, "invalid invitation")
		return
	cancel_invite(client_id) # error check, client is not supposed to send two invites
	
	var inviter = players.get_username(client_id)
	var invitee_id = players.get_client_id(invitee)
	if inviter != null and invitee_id != null:
		invitations.send_invite(client_id, inviter, invitee_id, invitee)
	else:
		Services.send_invite_error(client_id, "failed to send invitation")

func _on_invite_rejected(invitation: Dictionary) -> void:
	Logger.debug("Main: _on_invite_rejected")
	if invitations.has_invite(invitation.inviter_id):
		invitations.remove_invite(invitation.inviter_id)
		Services.send_invite_rejected(invitation.inviter_id, invitation)

func _on_invite_accepted(invitation: Dictionary) -> void:
	# remove the invitation that was send out by the invitee previously
	if invitations.has_invite(invitation.invitee_id):
		Logger.debug("Main: _on_invite_accepted")
		var old_invite = invitations.get_invite(invitation.invitee_id)
		print(old_invite)
		Services.send_invite_cancelled(old_invite.invitee_id, old_invite)
		invitations.remove_invite(invitation.invitee_id)
	
	# TODO remove all invitations that the inviter is associated with
	
	waitingroom.remove_client(invitation.invitee_id)
	waitingroom.remove_client(invitation.inviter_id)
	# Start Game
	var players = [
		{"username": invitation.inviter, "id": invitation.inviter_id, "colour": Global.COLOUR_GREEN}, 
		{"username": invitation.invitee, "id": invitation.invitee_id, "colour": Global.COLOUR_BLUE}
		]
	game_manager.start_game("1", players)

func _on_invite_cancelled(client_id: int) -> void:
	Logger.debug("Main: _on_invite_cancelled")
	cancel_invite(client_id)

func cancel_invite(invitation_id: int) -> bool:
	if invitations.has_invite(invitation_id):
		var invite = invitations.get_invite(invitation_id)
		Services.send_invite_cancelled(invite.invitee_id, invite)
		invitations.remove_invite(invitation_id)
		return true
	return false

# Game

func _on_player_left_game(client_id) -> void:
	game_left_by(client_id)
	waitingroom.add(client_id, players.get_username(client_id))

func game_left_by(client_id: int) -> void:
	var game_id = game_manager.player_in_game[client_id]
	var clients_in_game = game_manager.get_clients_in_game(game_id)
	for c in clients_in_game:
		if c == client_id:
			continue
		waitingroom.add(c, players.get_username(c))
		Services.player_left_game(c)
	game_manager.terminate_game(game_id)
