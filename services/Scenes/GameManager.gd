extends Node

onready var game_template: = preload("res://Scenes/GameTemplate.tscn")
onready var player_template =preload("res://Scenes/PlayerTemplate.tscn")

onready var test_level = preload("res://Scenes/Levels/TestLevel1.tscn")

func start_game(lobby: Dictionary) -> void:
	print("GameManager: starting game")
	var new_game = game_template.instance()
	new_game.name = str(gen_game_id())
	for player in lobby.players:
		var new_player = player_template.instance()
		new_player.name = str(player.id)
		new_game.add_child(new_player, true)
	add_child(new_game, true)
	for player in lobby.players:
		Services.pre_configure_game(player.id, test_level)

func _on_done_preconfiguring(client_id) -> void:
	print("done preconfiguring: " + client_id)

func gen_game_id() -> int:
	randomize()
	var n: int = randi() * 8
	return n
