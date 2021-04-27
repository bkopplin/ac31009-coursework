extends WindowDialog

signal cancel_invitation


onready var invitation_label = get_node("InvitationText")

var template = "Waiting for %s to accept invite."

func show_message(invitee: String) -> void:
	visible = true
	invitation_label.text =  template % invitee

func disable() -> void:
	visible = false

func _on_CancelInvite_pressed() -> void:
	visible = false
	emit_signal("cancel_invitation")


