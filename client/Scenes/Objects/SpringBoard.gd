extends Node2D

onready var texture_up: = get_node("Textures/springboardUp")
onready var texture_down: = get_node("Textures/springboardDown")

func _on_JumpDetector_body_entered(body: Node) -> void:
	print("spring board entered")
	print($JumpDetector.global_position.y)
	print(body.global_position.y)


func _on_PushDetector_body_entered(body: Node) -> void:
	print("push_detector entered")
	print($JumpDetector.global_position.y)
	print(body.global_position.y)
	texture_up.visible = false
	texture_down.visible = true


func _on_PushDetector_body_exited(body: Node) -> void:
	print("push_detector exited")
	print($JumpDetector.global_position.y)
	print(body.global_position.y)
	texture_up.visible = true
	texture_down.visible = false
