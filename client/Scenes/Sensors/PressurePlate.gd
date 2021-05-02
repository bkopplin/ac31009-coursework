extends Area2D
class_name PressurePlate

signal activated
signal deactivated

onready var button_pressed: = get_node("Textures/ButtonPressed")
onready var button_released: = get_node("Textures/ButtonReleased")


func _on_body_entered(body: Node) -> void:
	emit_signal("activated")
	button_released.visible = false
	button_pressed.visible = true


func _on_body_exited(body: Node) -> void:
	emit_signal("deactivated")
	button_released.visible = true
	button_pressed.visible = false

