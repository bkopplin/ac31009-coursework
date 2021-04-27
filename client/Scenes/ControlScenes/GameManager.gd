extends Node2D

signal show_dialog

onready var main: = get_node("/root/Main")
onready var level_node: = get_node("Levels")
onready var player_nodes: = get_node("Players")
onready var hud_node: = get_node("CanvasLayer/HUD")
onready var info_dialog: = get_node("CanvasLayer/InfoDialog")
onready var menu_dialog: = get_node("CanvasLayer/MenuDialog")

var last_state_t = 0
var world_states: Array
var render_offset: = 100

var player_data: Array
var other_players: Array
var current_level_id: String

func _ready() -> void:
	self.connect("show_dialog", info_dialog, "_on_show_dialog")

func _on_pre_configure_game(game_obj: Dictionary) -> void:
	"""
	game_obj = {
		game_id : the game ID of the current game
		players : [username, id, colour]
		selected_level: ID of the selected level
	}
	"""
	# TODO
	if not game_obj.has("selected_level"):
		pass
	
	Global.game_id = game_obj.game_id
	load_level(game_obj.current_level)
	player_data = game_obj.players
	
	for player in game_obj.players:
		var player_colour = player.colour
		var player_scene: Node
		if player.id == Global.unique_game_id:
			if player.colour == "green":
				player_scene = preload("res://Scenes/Actors/PlayerGreen.tscn").instance()
			else:
				player_scene = preload("res://Scenes/Actors/PlayerBlue.tscn").instance()
		else:
			if player.colour == "green":
				player_scene = preload("res://Scenes/Actors/GenericPlayerGreen.tscn").instance()
			else:
				player_scene = preload("res://Scenes/Actors/GenericPlayerBlue.tscn").instance()
			
			other_players.append(player.id)
		
		player_scene.name = str(player.id)
		player_scene.set_colour(player_colour)
		player_scene.position = get_spawnpoint(player_colour)
		player_nodes.add_child(player_scene, true)
		
	hud_node.visible = true
	visible = true
	main.start_game()
	Services.done_preconfiguring(game_obj.game_id)

func load_level(level_id: String) -> bool:
	var level_path = "res://Scenes/Levels/" + level_id + ".tscn"
	var level_resource = load(level_path)
	
	if level_id == "last_level":
		show_dialog_wip()
		return false
		
	if level_resource == null:
		show_dialog_level_not_found()
		return false
		
	for child in level_node.get_children():
		level_node.remove_child(child)

	var level_instance = level_resource.instance()
	level_node.add_child(level_instance)
	current_level_id = level_id
	return true

func get_spawnpoint(colour: String) -> Vector2:
	return level_node.get_node("Level").get_spawnpoint(colour)

func _on_post_configure_game() -> void:
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
				get_node("Players/" + str(player_id)).move_to(new_pos)

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
				get_node("Players/" + str(player_id)).move_to(new_pos)


func _on_load_next_level(level_name: String) -> void:
	if load_level(level_name):
	
		for player in player_data:
			get_node("Players/" + str(player.id)).position = get_spawnpoint(player.colour)

func _on_player_left_game() -> void:
	show_dialog_player_left()

func show_dialog_wip() -> void:
		emit_signal("show_dialog", "work in progress", "you've reached the end of the game. More levels will follow soon")
		get_tree().paused = true

func show_dialog_level_not_found() -> void:
		emit_signal("show_dialog", "error", "the requested level doesn't exist")
		get_tree().paused = true

func show_dialog_player_left() -> void:
		emit_signal("show_dialog", "game end", "the other player lost connection or left the game")
		get_tree().paused = true

func end_game() -> void:
	for p in player_nodes.get_children():
		player_nodes.remove_child(p)
	
	remove_child(level_node.get_node("Level"))
	set_physics_process(false)
	visible = false
	hud_node.visible = false


func _on_OpenMenu_pressed() -> void:
	if not menu_dialog.visible:
		menu_dialog.visible = true
