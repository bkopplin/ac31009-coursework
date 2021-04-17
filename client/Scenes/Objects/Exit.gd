extends Area2D

func _on_body_entered(body: Node) -> void:
	print("Loading next level")
	Services.level_finished()
