extends Area2D

func _on_body_entered(body: Node) -> void:
	Services.exit_area_entered()


func _on_Exit_body_exited(body: Node) -> void:
	Services.exit_area_left()
