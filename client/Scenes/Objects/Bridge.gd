extends StaticBody2D

onready var collision_shape: = get_node("CollisionShape2D")

func _on_BluePressurePlate_activated() -> void:
	self.visible = true

func _on_BluePressurePlate_deactivated() -> void:
	self.visible = false

func set_active(active: bool) -> void:
	print("set_active: " + str(active))
	self.visible = active
	collision_shape.disabled = not active
	
