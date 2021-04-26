extends StaticBody2D
class_name Platform

onready var collision_shape: = get_node("CollisionShape2D")
var active_sensors: = 0 setget set_active_sensors
export(bool) var hide_on_start
export(bool) var stays_activated = false # if true, the platform doesn't change state once activated
export(int) var required_active_sensors = 1

var is_active: = false
var action_activated: FuncRef
var action_deactivated: FuncRef

func _ready() -> void:
	if hide_on_start:
		collision_shape.set_deferred("disabled", true)
		visible = false
		action_activated = funcref(self, "show")
		action_deactivated = funcref(self, "hide")
	else:
		action_activated = funcref(self, "hide")
		action_deactivated = funcref(self, "show")

func set_active_sensors(n: int) -> void:
	active_sensors = n if n >= 0 else 0

"""
func show() -> void:
	self.active_sensors += 1
	visible = true
	collision_shape.set_deferred("disabled", false)

func hide() -> void:
	self.active_sensors -= 1
	if active_sensors == 0:
		visible = false
		collision_shape.set_deferred("disabled", true)
"""
func _on_activated() -> void:
	active_sensors += 1
	if active_sensors == required_active_sensors:
		is_active = true
		action_activated.call_func()

func _on_deactivated() -> void:
	active_sensors -= 1
	print(active_sensors)
	if active_sensors == 0 and not (stays_activated and is_active):
		is_active = false
		action_deactivated.call_func()
	
func show() -> void:
	visible = true
	collision_shape.set_deferred("disabled", false)

func hide() -> void:
	visible = false
	collision_shape.set_deferred("disabled", true)
