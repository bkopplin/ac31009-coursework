extends WindowDialog

signal return_to_homescreen

onready var main: = get_node("/root/Main")

func _ready() -> void:
	self.connect("return_to_homescreen", main, "_on_return_to_homescreen")

func _on_ContinueButton_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_ReturnButton_pressed() -> void:
	visible = false
	emit_signal("return_to_homescreen")
	Services.leave_game()

