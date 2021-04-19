extends WindowDialog

signal invitation_accepted
signal invitation_rejected

onready var invitation_label = get_node("InvitationText")

var invitation_template = "%s sends you an invite."

func show_invitation(inviter: String) -> void:
	visible = true
	invitation_label.text =  invitation_template % inviter


func _on_AcceptInviteButton_pressed() -> void:
	visible = false
	emit_signal("invitation_accepted")


func _on_RejectInviteButton_pressed() -> void:
	visible = false
	emit_signal("invitation_rejected")
