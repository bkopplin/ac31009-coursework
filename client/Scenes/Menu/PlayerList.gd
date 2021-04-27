extends MenuScreen

onready var available_players = get_node("MainContainer/AvailablePlayers")
onready var invitation_dialog = get_node("InvitationDialog")
onready var username_label = get_node("NavBar/HBoxContainer/UsernameLabel")
onready var invitation_send_dialog: = get_node("InvitationSendDialog")

var invitation_queue: Array # pending invitations

func _on_InviteButton_pressed() -> void:
	var selected = get_selected_item(available_players)
	print("selected: ")
	print(selected)
	Services.send_invite(selected)
	invitation_send_dialog.show_message(selected)

func get_selected_item(list: ItemList) -> String:
	var selected: String = ""
	if available_players.is_anything_selected():
		var selected_items: PoolIntArray = available_players.get_selected_items()
		selected = available_players.get_item_text(selected_items[0]) if selected_items.size() == 1 else ""
	return selected

func _on_Services_return_verification_result(result) -> void:
	username_label.text = "Logged in as " + Global.username if result else "not logged in"
	hide_error()

func update_available_players(players: Array) -> void:
	available_players.clear()
	players.erase(Global.username)
	if players.size() > 0:
		for player in players:
			available_players.add_item(player)
	else:
		available_players.add_item("you're alone", null, false)

func _on_Services_invitation_received(invitation: Dictionary) -> void:
	invitation_queue.append(invitation)
	show_invitation()
	

func _on_Services_invitation_rejected(invitation: Dictionary) -> void:
	var msg = "Inivation by " + invitation.invitee + " rejected: " + str(invitation.message)
	show_error(msg)
	invitation_send_dialog.disable()

func show_invitation() -> void:
	if invitation_queue.size() > 0:
		var inviter = invitation_queue[0].inviter
		invitation_dialog.show_invitation(inviter)


func _on_Services_services_disconnected() -> void:
	update_available_players([])
	show_error("Services disconnected")
	
func _on_invitation_cancelled(invitation: Dictionary) -> void:
	print("PlayerList: _on_invitation_cancelled")
	print(invitation_queue)
	if invitation_queue[0].inviter_id == invitation.inviter_id:
		print("invitation is now cancelled")
		invitation_dialog.disable()
	invitation_queue.erase(invitation)

func _on_InvitationDialog_invitation_accepted() -> void:
	var invitation = invitation_queue.pop_front()
	Services.accept_invite(invitation)
	show_invitation()


func _on_InvitationDialog_invitation_rejected() -> void:
	var invitation = invitation_queue.pop_front()
	Services.reject_invite(invitation)
	show_invitation()


func _on_InvitationSendDialog_cancel_invitation() -> void:
	Services.cancel_invite()

func game_started() -> void:
	invitation_send_dialog.disable()
