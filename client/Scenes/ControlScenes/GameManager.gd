extends Node2D

onready var main = get_node("/root/Main")

func _on_pre_configure_game(game_obj: Dictionary) -> void:
	"""
	game_obj = {
		game_id : the game ID of the current game
		players : [username, client_id, colour]
		selected_level: ID of the selected level
	}
	"""
	print("preconfiguring game with game_obj: " + str(game_obj))
	if not game_obj.has("selected_level"):
		pass

	var level_path = "res://Scenes/Levels/" + str(game_obj.selected_level) + ".tscn"
	var world = load(level_path).instance()
	add_child(world)
	main.start_game()
	
	for player in game_obj.players:
		var player_colour = player.colour
		var player_scene
		if player.id == Global.unique_game_id:
			player_scene = preload("res://Scenes/Actors/Player.tscn").instance()
		else:
			player_scene = preload("res://Scenes/Actors/GenericPlayer.tscn").instance()
			
		player_scene.set_colour(player_colour)
		player_scene.position = world.get_spawnpoint(player_colour)
		add_child(player_scene, true)
	# Tell server
	Services.done_preconfiguring(game_obj.game_id)

func _on_post_configure_game() -> void:
	print("post configuring game")
	set_physics_process(true)

func _on_receive_world_state(world_state) -> void:
	print("world state received: " + str(world_state))
