extends KinematicBody2D

export var texture_green: Texture
export var texture_blue: Texture

var colour: String setget set_colour

var velocity: = Vector2()
export var speed: = Vector2(400, 800)
export var gravity: int = 1500
var direction: = Vector2()


func _physics_process(delta: float) -> void:
	direction = calc_direction()
	velocity = calc_velocity(velocity, direction, speed)
	velocity = move_and_slide(velocity, Vector2.UP)
	generate_player_state()

func calc_velocity(velocity: Vector2, direction: Vector2, speed: Vector2) -> Vector2:
	var v = velocity
	v.x = direction.x * speed.x
	v.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		v.y = direction.y * speed.y
	return v

func calc_direction() -> Vector2:
	var d = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0
	)
	return d

func generate_player_state() -> void:
	var player_state: Dictionary
	player_state.position = self.position
	player_state.t = OS.get_system_time_msecs()
	Services.send_player_state(Global.game_id, player_state)


func set_colour(_colour: String) -> void:
	print("set color " + _colour)
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
