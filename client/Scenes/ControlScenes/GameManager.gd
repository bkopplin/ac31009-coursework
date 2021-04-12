extends Node2D

onready var main = get_node("/root/Main")
var last_state_t = 0
var world_state_buffer: Array
var render_offset: = 100
var other_players: Array

func _on_pre_configure_game(game_obj: Dictionary) -> void:
	"""
	game_obj = {
		game_id : the game ID of the current game
		players : [username, id, colour]
		selected_level: ID of the selected level
	}
	"""
	print("preconfiguring game with game_obj: " + str(game_obj))
	if not game_obj.has("selected_level"):
		pass
	
	Global.game_id = game_obj.game_id
	var level_path = "res://Scenes/Levels/" + str(game_obj.selected_level) + ".tscn"
	var world = load(level_path).instance()
	add_child(world)
	main.start_game()
	
	for player in game_obj.players:
		var player_colour = player.colour
		var player_scene: Node
		if player.id == Global.unique_game_id:
			player_scene = preload("res://Scenes/Actors/Player.tscn").instance()
		else:
			player_scene = preload("res://Scenes/Actors/GenericPlayer.tscn").instance()
			other_players.append(player.id)
		
		player_scene.name = str(player.id)
		player_scene.set_colour(player_colour)
		player_scene.position = world.get_spawnpoint(player_colour)
		add_child(player_scene, true)
	# Tell server
	Services.done_preconfiguring(game_obj.game_id)

func _on_post_configure_game() -> void:
	print("post configuring game")
	set_physics_process(true)

func _on_receive_world_state(world_state) -> void:
	if world_state.t > last_state_t:
		world_state_buffer.append(world_state)
		last_state_t = world_state.t


func _physics_process(delta: float) -> void:
	if world_state_buffer.size() > 1:
		var render_time = OS.get_system_time_msecs() - render_offset

		if world_state_buffer.size() > 2 and render_time > world_state_buffer[2].t:
			world_state_buffer.pop_front()

		if world_state_buffer.size() > 2: # interpolation
			for player_id in other_players:
				if world_state_buffer[0].positions.has(player_id):
					get_node(str(player_id)).move_to(world_state_buffer[0].positions[player_id])

		elif render_time > world_state_buffer[1].t: #extrapolation
			pass
