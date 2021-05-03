extends KinematicBody2D
class_name GenericPlayer

export var texture_green: Texture
export var texture_blue: Texture

var colour: String setget set_colour

func set_colour(_colour: String) -> void:
	colour = _colour
	var s = Sprite.new()
	if colour == "blue":
		s.texture = texture_blue
	
	elif colour == "green":
		s.texture = texture_green
	add_child(s)

func _get_configuration_warning() -> String:
	var warning = ""
	if texture_blue == null:
		warning += "texture_blue may not be empty"
	if texture_green == null:
		warning += "texture_green may not be empty"
	return warning

func move_to(position: Vector2) -> void:
	set_position(position)
