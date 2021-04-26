extends Node2D

onready var hint_text = get_node("HintText")

func _ready() -> void:
	hint_text.visible = false

func _on_Area2D_body_entered(body: Node) -> void:
	hint_text.visible = true


func _on_Area2D_body_exited(body: Node) -> void:
	hint_text.visible = false
