extends Node2D

onready var main = get_node("/root/Main")
var last_state_t = 0
var world_states: Array
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
		world_states.append(world_state)
		last_state_t = world_state.t


func _physics_process(delta: float) -> void:
	if world_states.size() > 1:
		var render_time = OS.get_system_time_msecs() - render_offset

		if world_states.size() > 2 and render_time > world_states[2].t:
			world_states.pop_front()
		
		# interpolation
		if world_states.size() > 2: 
			var p = float(render_time - world_states[1].t) / float(world_states[2].t - world_states[1].t)
			for player_id in world_states[2].positions:
				
				if player_id == Global.unique_game_id:
					continue
				
				if not world_states[1].positions.has(player_id) or not world_states[2].positions.has(player_id):
					continue
				var new_pos = lerp(world_states[1].positions[player_id], world_states[2].positions[player_id], p)
				get_node(str(player_id)).move_to(new_pos)

		# extrapolation
		else: 
			var p = float(render_time - world_states[0].t) / float(world_states[1].t - world_states[0].t) - 1.00
			for player_id in world_states[1].positions:
				
				if player_id == Global.unique_game_id:
					continue
				
				if not world_states[1].positions.has(player_id) or not world_states[0].positions.has(player_id):
					continue
					
				var pos_delta = world_states[1].positions[player_id] - world_states[0].positions[player_id]
				var new_pos = world_states[1].positions[player_id] + (pos_delta * p)
				get_node(str(player_id)).move_to(new_pos)
