extends Area2D

signal activated
signal deactivated


func _on_BluePressurePlate_body_entered(body: Node) -> void:
	emit_signal("activated")


func _on_BluePressurePlate_body_exited(body: Node) -> void:
	emit_signal("deactivated")
