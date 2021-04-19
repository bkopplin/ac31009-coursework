extends MenuScreen

onready var available_players = get_node("MainContainer/AvailablePlayers")
onready var invitation_dialog = get_node("InvitationDialog")
onready var invitation_label = get_node("InvitationDialog/InvitationText")
onready var username_label = get_node("NavBar/HBoxContainer/UsernameLabel")

var invitation_queue: Array # pending invitations

var invitation_template = "%s sends you an invite."

func _ready() -> void:
	pass


func _on_InviteButton_pressed() -> void:
	var selected = get_selected_item(available_players)
	print("sending invite to " + str(selected))
	Services.invite(selected)

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
	print("PlayerList: update_available_players: players: " + str(players))
	available_players.clear()
	players.erase(Global.username)
	if players.size() > 0:
		for player in players:
			available_players.add_item(player)
	else:
		available_players.add_item("you're alone", null, false)

func _on_Services_invitation_received(invitation: Dictionary) -> void:
	print("PlayerList: invitation received by " + str(invitation))
	invitation_queue.append(invitation)
	show_invitation()
	

func _on_Services_invitation_rejected(invitation: Dictionary) -> void:
	var msg = "Inivation by " + invitation.invitee + " rejected: " + str(invitation.message)
	show_error(msg)


func _on_AcceptInviteButton_pressed() -> void:
	var invitation = invitation_queue.pop_front()
	Services.accept_invitation(invitation)
	invitation_dialog.visible = false
	show_invitation()

func _on_RejectInviteButton_pressed() -> void:
	var invitation = invitation_queue.pop_front()
	Services.reject_invitation(invitation)
	invitation_dialog.visible = false
	show_invitation()

func show_invitation() -> void:
	if not invitation_dialog.visible and invitation_queue.size() > 0:
		invitation_dialog.visible = true
		invitation_label.text =  invitation_template % invitation_queue[0].inviter


func _on_Services_services_disconnected() -> void:
	update_available_players([])
	show_error("Services disconnected")
	
