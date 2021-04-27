extends Node
class_name Invitations

var invitations: Dictionary

func send_invite(
	_inviter_id: int, 
	_inviter: String, 
	_invitee_id: int, 
	_invitee: String
	):
	"""
	Creates a new invitation and sends it to the invitee.
	Error checking, especially for valid client_ids, is the responsibility
	of the caller.
	"""

	var invitation: Dictionary
	invitation.inviter = _inviter
	invitation.invitee = _invitee
	invitation.inviter_id = _inviter_id
	invitation.invitee_id = _invitee_id
	invitation.message = ""
	invitation.timestamp = OS.get_system_time_secs()
	
	if invitation.inviter == invitation.invitee:
		Services.send_invite_error(_inviter_id, "you cannot invite yourself")
		return
		
	if invitation.invitee_id <= 0:
		var message = str(invitation.invitee) + " is not available on server"
		Services.send_invite_error(_inviter_id, message)
		return
	
	var invitation_id = invitation.inviter_id # only one invitation per client allowed
	invitations[invitation_id] = invitation
	Services.send_invite(_invitee_id, invitation)

func remove_invite(invitation_id: int) -> void:
	if invitations.has(invitation_id):
		invitations.erase(invitation_id)

func get_invite(invitation_id: int) -> Dictionary:
	return invitations[invitation_id]

func has_invite(invitation_id: int) -> bool:
	return true if invitations.has(invitation_id) else false
