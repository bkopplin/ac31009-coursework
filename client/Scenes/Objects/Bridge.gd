extends StaticBody2D

onready var collision_shape: = get_node("CollisionShape2D")
var active_sensors: = 0 setget set_active_sensors

func _ready() -> void:
	collision_shape.set_deferred("disabled", true)
	
func set_active_sensors(n: int) -> void:
	print ("setting active sensors")
	active_sensors = n if n >= 0 else 0

func show() -> void:
	self.active_sensors += 1
	visible = true
	collision_shape.set_deferred("disabled", false)

func hide() -> void:
	self.active_sensors -= 1
	if active_sensors == 0:
		visible = false
		collision_shape.set_deferred("disabled", true)

