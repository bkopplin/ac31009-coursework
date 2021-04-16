extends Node

onready var game_template: = preload("res://Scenes/GameTemplate.tscn")
onready var player_template =preload("res://Scenes/PlayerTemplate.tscn")

onready var test_level = preload("res://Scenes/Levels/TestLevel1.tscn")

func start_game(lobby: Dictionary) -> void:
	print("GameManager: starting game")
	var new_game = game_template.instance()
	new_game.name = str(gen_game_id())
	add_child(new_game, true)
	
	var game_obj: Dictionary
	game_obj.game_id = new_game.name
	game_obj.players = lobby.players
	game_obj.selected_level = lobby.selected_level

	
	for player in lobby.players:
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

