extends Node2D

onready var main = get_node("/root/Main")

func _on_pre_configure_game(level_id, player_colours) -> void:
	# Load World
	var world = preload("res://Scenes/Levels/1.tscn").instance()
	add_child(world)
	main.start_game()

	# Load my player
	var player = preload("res://Scenes/Actors/Player.tscn").instance()
	# set name to peerID
	player.set_colour("green")
	player.position = world.get_spawnpoint("green")
	add_child(player, true)
	
	# load other players
	var other_player = preload("res://Scenes/Actors/GenericPlayer.tscn").instance()
	other_player.set_colour("blue")
	other_player.position = world.get_spawnpoint("blue")
	add_child(other_player)
	
	# Tell server

