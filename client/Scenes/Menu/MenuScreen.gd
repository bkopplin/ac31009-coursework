extends Control
class_name MenuScreen

onready var error_dialog = get_node("ErrorDialog")

func show_error(message: String) -> void:
	error_dialog.dialog_text = message
	error_dialog.visible = true

func hide_error() -> void:
	error_dialog.visible = false
