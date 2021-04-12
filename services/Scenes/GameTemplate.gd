extends Node2D

var player_state_buffer: Dictionary
var players_done_preconfiguring: Array

func _on_done_preconfiguring(client_id: int) -> void:
	print("in Game: _on_done_preconfiguring: " + str(client_id))
	players_done_preconfiguring.append(client_id)
	if players_done_preconfiguring.size() == 2:
		for client_id in players_done_preconfiguring:
			Services.post_configure_game(client_id)

func _on_receive_player_state(client_id: int, player_state) -> void:
	print("received player state from " + str(client_id) + " : " + str(player_state))
	if player_state_buffer[client_id].t < player_state.t:
		player_state_buffer[client_id] = player_state

func _physics_process(delta: float) -> void:
	pass
