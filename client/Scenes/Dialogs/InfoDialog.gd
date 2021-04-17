extends WindowDialog

signal return_to_homescreen
onready var message_label: = get_node("message")
onready var main: = get_node("/root/Main")

func _ready() -> void:
	self.connect("return_to_homescreen", main, "_on_return_to_homescreen")

func _on_show_dialog(title: String, message: String) -> void:
	window_title = title
	message_label.text = message
	visible = true

func _on_ReturnButton_pressed() -> void:
	visible = false
	emit_signal("return_to_homescreen")

