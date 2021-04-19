extends Node

onready var game_template: = preload("res://Scenes/GameTemplate.tscn")
onready var player_template =preload("res://Scenes/PlayerTemplate.tscn")

var player_in_game: Dictionary # player_id: game_id

func start_game(lobby: Dictionary) -> void:
	print("GameManager: starting game")
	var new_game = game_template.instance()
	new_game.name = str(gen_game_id())
	new_game.current_level_id = lobby.selected_level
	new_game.players = lobby.players
	add_child(new_game, true)
	
	var game_obj: Dictionary
	game_obj.game_id = new_game.name
	game_obj.players = lobby.players
	game_obj.current_level = lobby.selected_level
	
	for player in lobby.players:
		player_in_game[player.id] = new_game.name
		Services.pre_configure_game(player.id, game_obj)
	

func _on_done_preconfiguring(client_id: int, game_id: String) -> void:
	print("done preconfiguring: " + str(client_id))
	if has_node(game_id):
		get_node(game_id)._on_done_preconfiguring(client_id)

func gen_game_id() -> int:
	randomize()
	var n: int = randi() * 8
	return n

func _on_receive_player_state(game_id: String, client_id: int, player_state) -> void:
	if has_node(game_id):
		get_node(game_id)._on_receive_player_state(client_id, player_state)

func _on_level_finished(game_id: String, client_id: int) -> void:
	print("level finished in GameManger")
	if has_node(game_id):
		get_node(game_id)._on_level_finished(game_id, client_id)

func _on_exit_area_entered(game_id: String, client_id: int) -> void:
	if has_node(game_id):
		get_node(game_id)._on_exit_area_entered(client_id)
	
func _on_exit_area_left(game_id: String, client_id: int) -> void:
	if has_node(game_id):
		get_node(game_id)._on_exit_area_left(client_id)

func _on_player_left_game(client_id: int):
	print("GameManager: _on_player_left_game: player disconnected, player_in_game: " + str(player_in_game))
	if not player_in_game.has(client_id):
		return
		
	var game_id: = str(player_in_game[client_id])
	if has_node(game_id):
		var game_node = get_node(game_id)
		for player in game_node.players_done_preconfiguring:
			if player == client_id:
				continue
			Services.player_left_game(player)
		remove_child(game_node)
